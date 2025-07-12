#!/usr/bin/env bash
set -euo pipefail

MODULES_DIR="infra/terraform/modules"
ROOT_MAIN="infra/terraform/main.tf"

echo "🔍 Scanning all Terraform modules and root module usage..."

TMP_MODVARS=$(mktemp)

# Find all module blocks and their arguments in the root main.tf (works for simple single-line args)
grep '^module "' "$ROOT_MAIN" | while read -r line; do
  module=$(echo "$line" | cut -d'"' -f2)
  inside=0
  while read -r l; do
    # detect module block start
    if [[ "$l" == *"module \"$module\""* ]]; then
      inside=1; continue
    fi
    # detect module block end
    if [[ $inside -eq 1 && "$l" =~ ^\} ]]; then
      inside=0; break
    fi
    # parse args
    if [[ $inside -eq 1 && "$l" =~ ^[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*=(.*) ]]; then
      arg=$(echo "$l" | cut -d'=' -f1 | tr -d ' ')
      echo "$module $arg" >> "$TMP_MODVARS"
    fi
  done < <(tail -n +$(grep -n "^module \"$module\"" "$ROOT_MAIN" | cut -d: -f1) "$ROOT_MAIN")
done

for module_path in "$MODULES_DIR"/*/; do
  module="$(basename "$module_path")"
  vars_tf="${module_path}variables.tf"
  all_vars=""

  # All var.something in *.tf
  for tf in "$module_path"*.tf; do
    [ -f "$tf" ] || continue
    all_vars="$all_vars $(grep -o 'var\.[a-zA-Z0-9_]\+' "$tf" | sed 's/var\.//g')"
  done

  # All arguments passed from root module
  MODVARS=$(grep "^$module " "$TMP_MODVARS" | awk '{print $2}')
  all_vars="$all_vars $MODVARS"

  # Remove duplicates, ignore empty
  for v in $(echo "$all_vars" | tr ' ' '\n' | sort -u | grep -v '^$'); do
    if ! grep -q "variable \"$v\"" "$vars_tf" 2>/dev/null; then
      echo "📦 [$module] Declaring variable \"$v\" in $vars_tf"
      cat >> "$vars_tf" <<EOF

variable "$v" {
  description = "Auto-detected input variable '$v'"
  type        = string
}
EOF
    fi
  done
done

rm -f "$TMP_MODVARS"

echo "✅ All module variables are now declared in their variables.tf files!"

echo
echo "🟢 Run the following to verify:"
echo "    cd infra/terraform && terraform init -input=false -backend=false"
echo "    terraform plan"
