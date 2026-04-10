#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

plugin_dirs=(
  "backend"
  "frontend"
  "dotnet"
  "blazor"
  "skills-only"
  "skills-dotnet"
)

failures=0

check_file_exists() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo "Missing file: $path"
    failures=$((failures + 1))
  fi
}

check_pointer_file() {
  local path="$1"
  local first_line
  local line_count

  first_line="$(sed -n '1p' "$path")"
  line_count="$(wc -l < "$path" | tr -d ' ')"

  if [[ "$line_count" == "1" && "$first_line" == ../* ]]; then
    local dir target
    dir="$(dirname "$path")"
    target="$(cd "$dir" && realpath -m "$first_line")"
    if [[ ! -e "$target" ]]; then
      echo "Broken pointer: $path -> $first_line"
      failures=$((failures + 1))
    fi
  fi
}

echo "Checking marketplace manifest..."
check_file_exists ".claude-plugin/marketplace.json"

echo "Checking plugin manifests and declared agents..."
for plugin_dir in "${plugin_dirs[@]}"; do
  manifest="$plugin_dir/.claude-plugin/plugin.json"
  check_file_exists "$manifest"

  if [[ -f "$manifest" ]]; then
    while IFS= read -r agent_path; do
      [[ -z "$agent_path" ]] && continue
      check_file_exists "$plugin_dir/${agent_path#./}"
    done < <(sed -n 's/^[[:space:]]*"\(\.\/agents\/[^"]*\)".*/\1/p' "$manifest")
  fi
done

echo "Checking plugin pointer files..."
while IFS= read -r path; do
  check_pointer_file "$path"
done < <(find backend frontend skills-only -type f | sort)

echo "Checking forked plugin content paths..."
while IFS= read -r path; do
  check_file_exists "$path"
done < <(find dotnet blazor skills-dotnet -type f | sort)

if (( failures > 0 )); then
  echo "Validation failed with $failures issue(s)."
  exit 1
fi

echo "Plugin structure validation passed."
