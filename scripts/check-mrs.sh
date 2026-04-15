#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="/Users/finnjanssens/Personal/obsidian/ITP/Daikin/Merge Request Reviews.md"
HOSTS=("gitlab.com" "git.inthepocket.org")

updated=$(date "+%Y-%m-%d %H:%M")

printf -- "---\nupdated: %s\n---\n\n# MRs Awaiting Review\n" "$updated" > "$OUTPUT_FILE"

for host in "${HOSTS[@]}"; do
  printf "\n## %s\n\n" "$host" >> "$OUTPUT_FILE"

  mrs=$(GITLAB_HOST="$host" glab api "merge_requests?reviewer_username=finn.janssens&state=opened&scope=all" 2>/dev/null | sed 's/[[:cntrl:]]//g' || echo "[]")

  if [ -z "$mrs" ] || [ "$mrs" = "[]" ]; then
    echo "No open MRs awaiting review." >> "$OUTPUT_FILE"
  else
    printf '%s' "$mrs" | jq -r '
      sort_by(.created_at) |
      .[] |
      (.web_url | split("/") | .[-4] // empty) as $project |
      "- [ ] **\($project)** [\(.title)](\(.web_url)) by \(.author.username) ➕ \(.created_at | split("T")[0]) #review"
    ' >> "$OUTPUT_FILE"
  fi
done
