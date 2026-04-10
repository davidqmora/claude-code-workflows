#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$repo_root"
target_marketplace="${HOME}/.claude/plugins/marketplaces/local-plugins"
dry_run=0

usage() {
  cat <<'EOF'
Sync local-source plugins from this repo into a Claude Code local marketplace.

Usage:
  ./scripts/sync-to-local-marketplace.sh [--source PATH] [--target PATH] [--dry-run]

Options:
  --source PATH   Source claude-code-workflows repo. Defaults to this repo root.
  --target PATH   Target local marketplace directory.
                  Defaults to ~/.claude/plugins/marketplaces/local-plugins
  --dry-run       Show planned changes without modifying files.
  --help          Show this help.
EOF
}

log() {
  printf '%s\n' "$*"
}

run_cmd() {
  if (( dry_run )); then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      source_dir="${2:?missing value for --source}"
      shift 2
      ;;
    --target)
      target_marketplace="${2:?missing value for --target}"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

source_dir="$(cd "$source_dir" && pwd)"
target_marketplace="${target_marketplace/#\~/$HOME}"
source_manifest="$source_dir/.claude-plugin/marketplace.json"
target_manifest="$target_marketplace/.claude-plugin/marketplace.json"
target_plugins_dir="$target_marketplace/plugins"

if [[ ! -f "$source_manifest" ]]; then
  printf 'Source marketplace manifest not found: %s\n' "$source_manifest" >&2
  exit 1
fi

python_output="$(
  SOURCE_MANIFEST="$source_manifest" TARGET_MANIFEST="$target_manifest" python3 <<'PY'
import json
import os
import sys

source_manifest = os.environ["SOURCE_MANIFEST"]
target_manifest = os.environ["TARGET_MANIFEST"]

with open(source_manifest, "r", encoding="utf-8") as f:
    source_data = json.load(f)

if os.path.exists(target_manifest):
    with open(target_manifest, "r", encoding="utf-8") as f:
        target_data = json.load(f)
else:
    target_data = {"name": "local-plugins", "plugins": []}

plugins = []
for entry in source_data.get("plugins", []):
    source = entry.get("source")
    if isinstance(source, str) and source.startswith("./"):
        plugins.append(
            {
                "name": entry["name"],
                "source_path": source,
                "description": entry.get("description", ""),
            }
        )

if not plugins:
    print("No local-source plugins found in source marketplace.", file=sys.stderr)
    sys.exit(1)

target_plugins = target_data.get("plugins", [])
preserved = []
for entry in target_plugins:
    name = entry.get("name")
    if not any(plugin["name"] == name for plugin in plugins):
        preserved.append(name)

print(json.dumps({"plugins": plugins, "preserved": preserved}, separators=(",", ":")))
PY
)"

plugin_names=()
plugin_source_paths=()
plugin_descriptions=()
preserved_names=()

while IFS=$'\t' read -r row_type col1 col2; do
  [[ -z "$row_type" ]] && continue
  if [[ "$row_type" == "plugin" ]]; then
    plugin_names+=("$col1")
    plugin_source_paths+=("$col2")
  elif [[ "$row_type" == "desc" ]]; then
    plugin_descriptions+=("$col1")
  elif [[ "$row_type" == "preserved" ]]; then
    preserved_names+=("$col1")
  fi
done < <(
  JSON_INPUT="$python_output" python3 <<'PY'
import json
import os

data = json.loads(os.environ["JSON_INPUT"])
for plugin in data["plugins"]:
    print("plugin\t%s\t%s" % (plugin["name"], plugin["source_path"]))
    print("desc\t%s\t" % plugin["description"])
for name in data["preserved"]:
    print("preserved\t%s\t" % name)
PY
)

if [[ ${#plugin_names[@]} -eq 0 ]]; then
  printf 'No vendorable plugins were discovered in %s\n' "$source_manifest" >&2
  exit 1
fi

log "Source marketplace: $source_dir"
log "Target marketplace: $target_marketplace"
log "Plugins to sync: ${plugin_names[*]}"

run_cmd mkdir -p "$target_plugins_dir"
run_cmd mkdir -p "$(dirname "$target_manifest")"

for i in "${!plugin_names[@]}"; do
  plugin_name="${plugin_names[$i]}"
  plugin_source_rel="${plugin_source_paths[$i]}"
  plugin_source_dir="$source_dir/${plugin_source_rel#./}"
  plugin_target_dir="$target_plugins_dir/$plugin_name"

  if [[ ! -d "$plugin_source_dir" ]]; then
    printf 'Source plugin directory not found: %s\n' "$plugin_source_dir" >&2
    exit 1
  fi

  log "Syncing $plugin_name"
  run_cmd rm -rf "$plugin_target_dir"
  run_cmd mkdir -p "$plugin_target_dir"
  run_cmd cp -a "$plugin_source_dir"/. "$plugin_target_dir/"
done

if (( dry_run )); then
  log
  log "Dry run only. marketplace.json preview:"
  TARGET_MANIFEST="$target_manifest" SOURCE_MANIFEST="$source_manifest" python3 <<'PY'
import json
import os

target_manifest = os.environ["TARGET_MANIFEST"]
source_manifest = os.environ["SOURCE_MANIFEST"]

with open(source_manifest, "r", encoding="utf-8") as f:
    source_data = json.load(f)

if os.path.exists(target_manifest):
    with open(target_manifest, "r", encoding="utf-8") as f:
        target_data = json.load(f)
else:
    target_data = {"name": "local-plugins", "plugins": []}

managed_names = set()
plugins_to_sync = []
for entry in source_data.get("plugins", []):
    source = entry.get("source")
    if isinstance(source, str) and source.startswith("./"):
        name = entry["name"]
        managed_names.add(name)
        plugins_to_sync.append(
            {
                "name": name,
                "source": f"./plugins/{name}",
                "description": entry.get("description", ""),
            }
        )

preserved_entries = [entry for entry in target_data.get("plugins", []) if entry.get("name") not in managed_names]
target_data["plugins"] = sorted(preserved_entries + plugins_to_sync, key=lambda entry: entry.get("name", ""))
print(json.dumps(target_data, indent=2, ensure_ascii=False))
PY
else
  TARGET_MANIFEST="$target_manifest" SOURCE_MANIFEST="$source_manifest" python3 <<'PY'
import json
import os

target_manifest = os.environ["TARGET_MANIFEST"]
source_manifest = os.environ["SOURCE_MANIFEST"]

with open(source_manifest, "r", encoding="utf-8") as f:
    source_data = json.load(f)

if os.path.exists(target_manifest):
    with open(target_manifest, "r", encoding="utf-8") as f:
        target_data = json.load(f)
else:
    target_data = {"name": "local-plugins", "plugins": []}

plugins_to_sync = []
managed_names = set()
for entry in source_data.get("plugins", []):
    source = entry.get("source")
    if isinstance(source, str) and source.startswith("./"):
        name = entry["name"]
        managed_names.add(name)
        plugins_to_sync.append(
            {
                "name": name,
                "source": f"./plugins/{name}",
                "description": entry.get("description", ""),
            }
        )

preserved_entries = [entry for entry in target_data.get("plugins", []) if entry.get("name") not in managed_names]
target_data["plugins"] = sorted(preserved_entries + plugins_to_sync, key=lambda entry: entry.get("name", ""))

if "name" not in target_data:
    target_data["name"] = "local-plugins"

with open(target_manifest, "w", encoding="utf-8") as f:
    f.write(json.dumps(target_data, indent=2, ensure_ascii=False) + "\n")
PY
  log "Updated marketplace manifest: $target_manifest"
fi

log
log "Preserved existing plugins: ${preserved_names[*]:-none}"
log "Synced plugins: ${plugin_names[*]}"
log
log "Syncing adds plugins to the local marketplace but does not install or enable them."
log "Install examples:"
for plugin_name in "${plugin_names[@]}"; do
  log "  /plugin install ${plugin_name}@local-plugins"
done
log
log "Overlap warnings:"
log "  - dev-workflows overlaps with dev-skills"
log "  - dev-workflows-dotnet and dev-workflows-blazor overlap with dev-skills-dotnet"
