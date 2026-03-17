#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
worktree=$(echo "$input" | jq -r '.worktree.name // empty')
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')

if [ -n "$used" ]; then
  used_display=$(printf "%.0f" "$used")
  usage_str="${used_display}%"
else
  usage_str="0%"
fi

if [ -n "$worktree" ]; then
  worktree_str="${worktree}"
else
  worktree_str="no worktree"
fi

GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

git_str=""
if [ -n "$current_dir" ] && cd "$current_dir" 2>/dev/null && git rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null)

  git_str="🌿 ${branch}"
  [ -n "$lines_added" ] && [ "$lines_added" -gt 0 ] && git_str="${git_str} $(printf "${GREEN}+${lines_added}${RESET}")"
  [ -n "$lines_removed" ] && [ "$lines_removed" -gt 0 ] && git_str="${git_str} $(printf "${RED}-${lines_removed}${RESET}")"
fi

if [ -n "$total_cost" ]; then
  cost_display=$(awk "BEGIN { printf \"%.2f\", $total_cost }")
  block_str="\$${cost_display}"
else
  block_str="\$0.00"
fi

printf "🤖 %s | 🧠 %s | 💰 %s\n🌳 %s | %s" "$model" "$usage_str" "$block_str" "$worktree_str" "$git_str"
