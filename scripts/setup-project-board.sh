#!/usr/bin/env bash
set -euo pipefail

OWNER="graygarbage"
REPO="HermesKey"
PROJECT_TITLE="HermesKey Roadmap"
ISSUES=(4 5 6 7 8 9 10 11 12 13 14 15 16)

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  }
}

need_cmd gh
need_cmd grep
need_cmd sed

if ! gh auth status -h github.com >/dev/null 2>&1; then
  printf 'GitHub CLI is not authenticated.\n' >&2
  exit 1
fi

if ! gh project list --owner "$OWNER" >/dev/null 2>&1; then
  cat >&2 <<'EOF'
GitHub Projects access is not available with the current token.
Run this first and complete the browser/device flow:

  gh auth refresh -h github.com -s project
EOF
  exit 1
fi

project_number="$(gh project list --owner "$OWNER" --format json --jq '.projects[] | select(.title=="'"$PROJECT_TITLE"'") | .number' | head -n1)"

if [[ -z "$project_number" ]]; then
  project_number="$(gh project create --owner "$OWNER" --title "$PROJECT_TITLE" --format json --jq '.number')"
fi

gh project link "$project_number" --owner "$OWNER" --repo "$OWNER/$REPO" >/dev/null 2>&1 || true

for issue in "${ISSUES[@]}"; do
  url="https://github.com/$OWNER/$REPO/issues/$issue"
  gh project item-add "$project_number" --owner "$OWNER" --url "$url" >/dev/null 2>&1 || true
  gh project item-edit "$project_number" --owner "$OWNER" --url "$url" --field "Status" --value "Todo" >/dev/null 2>&1 || true
done

printf 'Project board ready: %s\n' "https://github.com/users/$OWNER/projects/$project_number"
printf 'You can open it with:\n  gh project view %s --owner %s --web\n' "$project_number" "$OWNER"
