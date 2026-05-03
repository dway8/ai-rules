#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

BLUE=$'\033[34m'; CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'

if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

TOTAL_SECS=$((DURATION_MS / 1000))
HOURS=$((TOTAL_SECS / 3600))
MINS=$(((TOTAL_SECS % 3600) / 60))
SECS=$((TOTAL_SECS % 60))
if [ "$HOURS" -gt 0 ]; then
  DURATION="${HOURS}h ${MINS}m"
else
  DURATION="${MINS}m ${SECS}s"
fi

PARENT=$(basename "$(dirname "$DIR")")
LEAF=$(basename "$DIR")
SHORT_DIR="$PARENT/$LEAF"

BRANCH=""
git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git -C "$DIR" branch --show-current 2>/dev/null)"

DIFF=""
if [ "$ADDED" -gt 0 ] || [ "$REMOVED" -gt 0 ]; then
  DIFF=" | ${GREEN}+${ADDED}${RESET} ${RED}-${REMOVED}${RESET}"
fi

printf "%s\n" "${BLUE}📁 ${SHORT_DIR}${RESET}${BRANCH} | ${CYAN}[$MODEL]${RESET}"
printf "%s\n" "${BAR_COLOR}${BAR}${RESET} ${PCT}% | ⏱️  ${DURATION}${DIFF}"
