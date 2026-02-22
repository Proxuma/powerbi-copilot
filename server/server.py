import json
import asyncio
import os
import time
import base64
import re
from pathlib import Path
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
import requests
from azure.identity import (
    InteractiveBrowserCredential,
    TokenCachePersistenceOptions,
    AuthenticationRecord
)
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine
from presidio_anonymizer.entities import OperatorConfig

# Config
CACHE_DIR = Path.home() / ".powerbi-mcp"
CACHE_DIR.mkdir(exist_ok=True)
AUTH_RECORD_PATH = CACHE_DIR / "auth_record.json"
TOKEN_CACHE_PATH = CACHE_DIR / "token_cache.bin"

# User config — loaded from config.json next to this file, or ~/.powerbi-mcp/config.json
CONFIG_PATH = Path(__file__).parent / "config.json"
GLOBAL_CONFIG_PATH = CACHE_DIR / "config.json"

def load_config():
    """Load user config from config.json (local first, then global fallback)."""
    for path in [CONFIG_PATH, GLOBAL_CONFIG_PATH]:
        if path.exists():
            try:
                with open(path, "r") as f:
                    return json.load(f)
            except Exception:
                pass
    return {}

USER_CONFIG = load_config()

# Scopes for both APIs
POWERBI_SCOPE = "https://analysis.windows.net/powerbi/api/.default"
FABRIC_SCOPE = "https://api.fabric.microsoft.com/.default"

server = Server("powerbi-connector")

# Singleton credential — initialized once
_credential = None
_token_cache = {}  # In-memory cache for tokens

# Presidio anonymization engines (singleton)
_analyzer = None
_anonymizer = None

def get_analyzer():
    """Get or create Presidio analyzer engine."""
    global _analyzer
    if _analyzer is None:
        from presidio_analyzer.nlp_engine import NlpEngineProvider
        provider = NlpEngineProvider(nlp_configuration={
            "nlp_engine_name": "spacy",
            "models": [{"lang_code": "en", "model_name": "en_core_web_sm"}]
        })
        nlp_engine = provider.create_engine()
        _analyzer = AnalyzerEngine(nlp_engine=nlp_engine)
    return _analyzer

def get_anonymizer():
    """Get or create Presidio anonymizer engine."""
    global _anonymizer
    if _anonymizer is None:
        _anonymizer = AnonymizerEngine()
    return _anonymizer

def anonymize_text(text: str, language: str = "en") -> str:
    """Anonymize PII in text using Presidio."""
    if not text or not isinstance(text, str):
        return text

    analyzer = get_analyzer()
    anonymizer = get_anonymizer()

    analysis_results = analyzer.analyze(
        text=text,
        language=language,
        score_threshold=0.4
    )

    operators = {
        "PERSON": OperatorConfig("replace", {"new_value": "<PERSON>"}),
        "EMAIL_ADDRESS": OperatorConfig("replace", {"new_value": "<EMAIL>"}),
        "PHONE_NUMBER": OperatorConfig("replace", {"new_value": "<PHONE>"}),
        "CREDIT_CARD": OperatorConfig("replace", {"new_value": "<CREDITCARD>"}),
        "IBAN_CODE": OperatorConfig("replace", {"new_value": "<IBAN>"}),
        "IP_ADDRESS": OperatorConfig("replace", {"new_value": "<IP_ADDRESS>"}),
        "LOCATION": OperatorConfig("replace", {"new_value": "<LOCATION>"}),
        "DATE_TIME": OperatorConfig("replace", {"new_value": "<DATE>"}),
        "NRP": OperatorConfig("replace", {"new_value": "<NATIONAL_ID>"}),
        "MEDICAL_LICENSE": OperatorConfig("replace", {"new_value": "<MEDICAL_ID>"}),
        "URL": OperatorConfig("replace", {"new_value": "<URL>"}),
        "US_SSN": OperatorConfig("replace", {"new_value": "<SSN>"}),
        "US_PASSPORT": OperatorConfig("replace", {"new_value": "<PASSPORT>"}),
        "US_DRIVER_LICENSE": OperatorConfig("replace", {"new_value": "<DRIVER_LICENSE>"}),
        "CRYPTO": OperatorConfig("replace", {"new_value": "<CRYPTO_WALLET>"}),
    }

    anonymized_result = anonymizer.anonymize(
        text=text,
        analyzer_results=analysis_results,
        operators=operators
    )

    return anonymized_result.text

def anonymize_json(data):
    """Anonymize JSON data by processing all string values."""
    if isinstance(data, str):
        return anonymize_text(data)
    elif isinstance(data, dict):
        return {k: anonymize_json(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [anonymize_json(item) for item in data]
    else:
        return data

def get_credential():
    """Get or create credential with persistent cache."""
    global _credential

    if _credential is not None:
        return _credential

    cache_options = TokenCachePersistenceOptions(
        name="powerbi-mcp",
        allow_unencrypted_storage=True
    )

    # Check for existing auth record
    auth_record = None
    if AUTH_RECORD_PATH.exists():
        try:
            with open(AUTH_RECORD_PATH, "r") as f:
                auth_data = json.load(f)
                auth_record = AuthenticationRecord.deserialize(json.dumps(auth_data))
        except Exception:
            pass

    if auth_record:
        # Reuse existing authentication — no browser popup
        _credential = InteractiveBrowserCredential(
            cache_persistence_options=cache_options,
            authentication_record=auth_record
        )
    else:
        # First time — browser popup required
        _credential = InteractiveBrowserCredential(
            cache_persistence_options=cache_options
        )

    return _credential

def save_auth_record(credential, scope):
    """Save auth record for reuse."""
    try:
        record = credential.authenticate(scopes=[scope])
        auth_data = json.loads(record.serialize())
        with open(AUTH_RECORD_PATH, "w") as f:
            json.dump(auth_data, f)
    except Exception:
        pass

def get_token(scope):
    """Get token with caching."""
    global _token_cache

    cache_key = scope
    if cache_key in _token_cache:
        cached = _token_cache[cache_key]
        if cached["expires_on"] > time.time() + 300:
            return cached["token"]

    credential = get_credential()
    token = credential.get_token(scope)

    _token_cache[cache_key] = {
        "token": token.token,
        "expires_on": token.expires_on
    }

    save_auth_record(credential, scope)
    return token.token

def get_powerbi_headers():
    return {
        "Authorization": f"Bearer {get_token(POWERBI_SCOPE)}",
        "Content-Type": "application/json"
    }

def get_fabric_headers():
    return {
        "Authorization": f"Bearer {get_token(FABRIC_SCOPE)}",
        "Content-Type": "application/json"
    }

def resolve_ids(arguments: dict, need_workspace: bool = True, need_dataset: bool = True) -> dict:
    """Resolve workspace/dataset IDs from arguments, falling back to config defaults."""
    result = dict(arguments)
    if need_workspace and "workspace_id" not in result:
        default_ws = USER_CONFIG.get("default_workspace_id", "")
        if default_ws:
            result["workspace_id"] = default_ws
    if need_dataset and "dataset_id" not in result:
        default_ds = USER_CONFIG.get("default_dataset_id", "")
        if default_ds:
            result["dataset_id"] = default_ds
    return result

def fetch_and_decode_schema(workspace_id: str, dataset_id: str) -> str:
    """Fetch schema and decode all base64 TMDL content to readable text."""
    response = requests.post(
        f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/semanticModels/{dataset_id}/getDefinition",
        headers=get_fabric_headers()
    )

    schema_data = None
    if response.status_code == 202:
        location = response.headers.get("Location")
        if location:
            for _ in range(30):
                time.sleep(2)
                result = requests.get(location, headers=get_fabric_headers())
                if result.status_code == 200:
                    data = result.json()
                    if data.get("status") == "Succeeded":
                        result_response = requests.get(
                            f"{location}/result",
                            headers=get_fabric_headers()
                        )
                        if result_response.ok:
                            schema_data = result_response.json()
                            break
                    elif data.get("status") == "Failed":
                        raise Exception(f"Failed to get schema: {data.get('error')}")
            if not schema_data:
                raise Exception("Timeout waiting for schema")
    else:
        response.raise_for_status()
        schema_data = response.json()

    decoded_content = []
    parts = schema_data.get("definition", {}).get("parts", [])
    for part in parts:
        payload = part.get("payload", "")
        payload_type = part.get("payloadType", "")
        path = part.get("path", "")

        if payload_type == "InlineBase64" and payload:
            try:
                decoded = base64.b64decode(payload).decode("utf-8")
                decoded_content.append(f"--- {path} ---\n{decoded}")
            except Exception:
                pass

    return "\n\n".join(decoded_content)

@server.list_tools()
async def list_tools():
    return [
        Tool(
            name="list_workspaces",
            description="List all Power BI workspaces you have access to",
            inputSchema={
                "type": "object",
                "properties": {},
                "required": []
            }
        ),
        Tool(
            name="list_datasets",
            description="List all datasets/semantic models in a workspace",
            inputSchema={
                "type": "object",
                "properties": {
                    "workspace_id": {"type": "string", "description": "Workspace ID (GUID). Optional if default_workspace_id is set in config.json."}
                },
                "required": []
            }
        ),
        Tool(
            name="execute_dax",
            description="Execute a DAX query on a dataset/semantic model",
            inputSchema={
                "type": "object",
                "properties": {
                    "dataset_id": {"type": "string", "description": "Dataset ID (GUID). Optional if default_dataset_id is set in config.json."},
                    "dax_query": {"type": "string", "description": "DAX query, e.g.: EVALUATE TOPN(10, 'Sales')"}
                },
                "required": ["dax_query"]
            }
        ),
        Tool(
            name="get_schema",
            description="WARNING: Returns the FULL schema (can be >10MB). Use 'search_schema' for targeted searches or 'list_measures' for a measures overview instead.",
            inputSchema={
                "type": "object",
                "properties": {
                    "workspace_id": {"type": "string", "description": "Workspace ID (GUID). Optional if default_workspace_id is set in config.json."},
                    "dataset_id": {"type": "string", "description": "Dataset/Semantic Model ID (GUID). Optional if default_dataset_id is set in config.json."}
                },
                "required": []
            }
        ),
        Tool(
            name="list_fabric_items",
            description="List all items in a Fabric workspace (reports, datasets, lakehouses, etc.)",
            inputSchema={
                "type": "object",
                "properties": {
                    "workspace_id": {"type": "string", "description": "Workspace ID (GUID). Optional if default_workspace_id is set in config.json."}
                },
                "required": []
            }
        ),
        Tool(
            name="search_schema",
            description="Search the schema for specific measures, columns, or tables. Returns only relevant definitions (not the full schema). Use this instead of get_schema for targeted searches.",
            inputSchema={
                "type": "object",
                "properties": {
                    "workspace_id": {"type": "string", "description": "Workspace ID (GUID). Optional if default_workspace_id is set in config.json."},
                    "dataset_id": {"type": "string", "description": "Dataset/Semantic Model ID (GUID). Optional if default_dataset_id is set in config.json."},
                    "search_term": {"type": "string", "description": "Search term (case-insensitive). E.g.: 'efficiency', 'variance', 'sales'"},
                    "context_lines": {"type": "integer", "description": "Number of context lines around each match (default: 25)", "default": 25}
                },
                "required": ["search_term"]
            }
        ),
        Tool(
            name="list_measures",
            description="List all measure names in a dataset (without full definitions). Useful to see which measures are available.",
            inputSchema={
                "type": "object",
                "properties": {
                    "workspace_id": {"type": "string", "description": "Workspace ID (GUID). Optional if default_workspace_id is set in config.json."},
                    "dataset_id": {"type": "string", "description": "Dataset/Semantic Model ID (GUID). Optional if default_dataset_id is set in config.json."}
                },
                "required": []
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    try:
        if name == "list_workspaces":
            response = requests.get(
                "https://api.powerbi.com/v1.0/myorg/groups",
                headers=get_powerbi_headers()
            )
            response.raise_for_status()
            data = response.json()
            workspaces = data.get("value", [])
            output = "Available workspaces:\n\n"
            for ws in workspaces:
                output += f"- {ws.get('name', 'Unknown')}\n  ID: {ws.get('id')}\n\n"
            return [TextContent(type="text", text=anonymize_text(output))]

        elif name == "list_datasets":
            args = resolve_ids(arguments, need_workspace=True, need_dataset=False)
            workspace_id = args.get("workspace_id")
            if not workspace_id:
                return [TextContent(type="text", text="Error: workspace_id is required. Provide it as an argument or set default_workspace_id in config.json.")]
            response = requests.get(
                f"https://api.powerbi.com/v1.0/myorg/groups/{workspace_id}/datasets",
                headers=get_powerbi_headers()
            )
            response.raise_for_status()
            data = response.json()
            datasets = data.get("value", [])
            output = "Datasets in workspace:\n\n"
            for ds in datasets:
                output += f"- {ds.get('name', 'Unknown')}\n  ID: {ds.get('id')}\n  Configured by: {ds.get('configuredBy', 'Unknown')}\n\n"
            return [TextContent(type="text", text=anonymize_text(output))]

        elif name == "execute_dax":
            args = resolve_ids(arguments, need_workspace=False, need_dataset=True)
            dataset_id = args.get("dataset_id")
            if not dataset_id:
                return [TextContent(type="text", text="Error: dataset_id is required. Provide it as an argument or set default_dataset_id in config.json.")]
            dax_query = arguments["dax_query"]
            response = requests.post(
                f"https://api.powerbi.com/v1.0/myorg/datasets/{dataset_id}/executeQueries",
                headers=get_powerbi_headers(),
                json={
                    "queries": [{"query": dax_query}],
                    "serializerSettings": {"includeNulls": True}
                }
            )
            response.raise_for_status()
            anonymized_data = anonymize_json(response.json())
            return [TextContent(type="text", text=json.dumps(anonymized_data, indent=2))]

        elif name == "get_schema":
            args = resolve_ids(arguments)
            workspace_id = args.get("workspace_id")
            dataset_id = args.get("dataset_id")
            if not workspace_id or not dataset_id:
                return [TextContent(type="text", text="Error: workspace_id and dataset_id are required. Provide them as arguments or set defaults in config.json.")]

            response = requests.post(
                f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/semanticModels/{dataset_id}/getDefinition",
                headers=get_fabric_headers()
            )

            if response.status_code == 202:
                location = response.headers.get("Location")
                if location:
                    for _ in range(30):
                        time.sleep(2)
                        result = requests.get(location, headers=get_fabric_headers())
                        if result.status_code == 200:
                            data = result.json()
                            if data.get("status") == "Succeeded":
                                result_response = requests.get(
                                    f"{location}/result",
                                    headers=get_fabric_headers()
                                )
                                if result_response.ok:
                                    anonymized_data = anonymize_json(result_response.json())
                                    return [TextContent(type="text", text=json.dumps(anonymized_data, indent=2))]
                            elif data.get("status") == "Failed":
                                return [TextContent(type="text", text=f"Failed: {data.get('error')}")]
                    return [TextContent(type="text", text="Timeout waiting for schema")]

            response.raise_for_status()
            anonymized_data = anonymize_json(response.json())
            return [TextContent(type="text", text=json.dumps(anonymized_data, indent=2))]

        elif name == "list_fabric_items":
            args = resolve_ids(arguments, need_workspace=True, need_dataset=False)
            workspace_id = args.get("workspace_id")
            if not workspace_id:
                return [TextContent(type="text", text="Error: workspace_id is required. Provide it as an argument or set default_workspace_id in config.json.")]
            response = requests.get(
                f"https://api.fabric.microsoft.com/v1/workspaces/{workspace_id}/items",
                headers=get_fabric_headers()
            )
            response.raise_for_status()
            items = response.json().get("value", [])
            output = "Items in workspace:\n\n"
            for item in items:
                output += f"- {item.get('displayName')} ({item.get('type')})\n  ID: {item.get('id')}\n\n"
            return [TextContent(type="text", text=anonymize_text(output))]

        elif name == "search_schema":
            args = resolve_ids(arguments)
            workspace_id = args.get("workspace_id")
            dataset_id = args.get("dataset_id")
            if not workspace_id or not dataset_id:
                return [TextContent(type="text", text="Error: workspace_id and dataset_id are required. Provide them as arguments or set defaults in config.json.")]
            search_term = arguments["search_term"]
            context_lines = arguments.get("context_lines", 25)

            decoded_schema = fetch_and_decode_schema(workspace_id, dataset_id)
            lines = decoded_schema.split("\n")

            matches = []
            pattern = re.compile(re.escape(search_term), re.IGNORECASE)

            for i, line in enumerate(lines):
                if pattern.search(line):
                    start = max(0, i - context_lines)
                    end = min(len(lines), i + context_lines + 1)
                    context = lines[start:end]
                    matches.append({
                        "line_number": i + 1,
                        "match_line": line.strip(),
                        "context": "\n".join(context)
                    })

            # Deduplicate overlapping contexts
            if matches:
                deduplicated = [matches[0]]
                for m in matches[1:]:
                    if m["line_number"] - deduplicated[-1]["line_number"] > context_lines * 2:
                        deduplicated.append(m)
                matches = deduplicated

            if not matches:
                return [TextContent(type="text", text=f"No matches found for '{search_term}'")]

            output = f"Found {len(matches)} results for '{search_term}':\n\n"
            for i, match in enumerate(matches[:10]):
                output += f"=== Match {i+1} (line {match['line_number']}) ===\n"
                output += match["context"]
                output += "\n\n"

            if len(matches) > 10:
                output += f"... and {len(matches) - 10} more results (refine your search term for more specific results)"

            return [TextContent(type="text", text=anonymize_text(output))]

        elif name == "list_measures":
            args = resolve_ids(arguments)
            workspace_id = args.get("workspace_id")
            dataset_id = args.get("dataset_id")
            if not workspace_id or not dataset_id:
                return [TextContent(type="text", text="Error: workspace_id and dataset_id are required. Provide them as arguments or set defaults in config.json.")]

            decoded_schema = fetch_and_decode_schema(workspace_id, dataset_id)

            measure_pattern = re.compile(r"^\s*measure\s+'([^']+)'|^\s*measure\s+(\S+)", re.MULTILINE | re.IGNORECASE)
            measures = []
            for match in measure_pattern.finditer(decoded_schema):
                measure_name = match.group(1) or match.group(2)
                if measure_name and measure_name not in measures:
                    measures.append(measure_name)

            if not measures:
                return [TextContent(type="text", text="No measures found in this model")]

            output = f"Found {len(measures)} measures:\n\n"
            for m in sorted(measures):
                output += f"- {m}\n"

            return [TextContent(type="text", text=anonymize_text(output))]

        else:
            return [TextContent(type="text", text=f"Unknown tool: {name}")]

    except requests.exceptions.HTTPError as e:
        error_msg = f"HTTP Error: {e.response.status_code}\n{e.response.text}"
        return [TextContent(type="text", text=anonymize_text(error_msg))]
    except Exception as e:
        return [TextContent(type="text", text=anonymize_text(f"Error: {str(e)}"))]

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())

if __name__ == "__main__":
    asyncio.run(main())
