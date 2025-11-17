#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/local_notify.sh [OPTIONS]

Options:
  --message "text"        Custom message content
  --status STATUS         Completion status: complete|blocked|question|error (default: complete)
  --milestone "M1"        Current milestone identifier
  --agent "AgentName"     Agent identifier (auto-detected from env if not provided)
  --details "text"        Additional details or context
  --webhook URL           Override webhook URL
  --no-sound              Skip playing alert sound

Environment variables:
  LOCAL_NOTIFY_WEBHOOK_URL   Discord-compatible webhook endpoint
  LOCAL_NOTIFY_DISABLE_SOUND Set to 1 to skip playing alert sound
  LOCAL_NOTIFY_SOUND         Custom sound file path
  AGENT_NAME                 Name/identifier of the agent (e.g., "Claude", "Cline", "Cursor")
  
Examples:
  # Milestone complete
  ./local_notify.sh --status complete --milestone "M1" --details "User auth implemented"
  
  # Blocked on dependency
  ./local_notify.sh --status blocked --milestone "M2" --details "Waiting for API keys"
  
  # Question for user
  ./local_notify.sh --status question --details "Should we use OAuth or API keys?"
USAGE
}

# Defaults
message=""
status="complete"
milestone=""
agent_name="${AGENT_NAME:-}"
details=""
webhook_override=""
play_sound=1

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --message)
      [[ $# -gt 1 ]] || { echo "[local_notify] --message requires a value" >&2; exit 2; }
      message="$2"
      shift 2
      ;;
    --status)
      [[ $# -gt 1 ]] || { echo "[local_notify] --status requires a value" >&2; exit 2; }
      status="$2"
      shift 2
      ;;
    --milestone)
      [[ $# -gt 1 ]] || { echo "[local_notify] --milestone requires a value" >&2; exit 2; }
      milestone="$2"
      shift 2
      ;;
    --agent)
      [[ $# -gt 1 ]] || { echo "[local_notify] --agent requires a value" >&2; exit 2; }
      agent_name="$2"
      shift 2
      ;;
    --details)
      [[ $# -gt 1 ]] || { echo "[local_notify] --details requires a value" >&2; exit 2; }
      details="$2"
      shift 2
      ;;
    --webhook)
      [[ $# -gt 1 ]] || { echo "[local_notify] --webhook requires a value" >&2; exit 2; }
      webhook_override="$2"
      shift 2
      ;;
    --no-sound)
      play_sound=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[local_notify] Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

# Auto-detect agent if not provided
if [[ -z "$agent_name" ]]; then
  # Try to detect from common environment variables or process info
  if [[ -n "${CLINE_VERSION:-}" ]]; then
    agent_name="Cline"
  elif [[ -n "${CURSOR_VERSION:-}" ]]; then
    agent_name="Cursor"
  elif [[ -n "${GITHUB_COPILOT:-}" ]]; then
    agent_name="Copilot"
  elif [[ -n "${ANTHROPIC_API_KEY:-}" ]] && [[ "${0}" == *"claude"* ]]; then
    agent_name="Claude"
  else
    agent_name="AI Agent"
  fi
fi

# Gather context
PROJECT="${PWD##*/}"
HOSTNAME="$(hostname)"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
GIT_BRANCH=""
if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"
fi

# Status emoji mapping for Discord
case "$status" in
  complete)
    status_emoji="✅"
    status_color=3066993  # Green
    ;;
  blocked)
    status_emoji="🚧"
    status_color=15158332  # Red
    ;;
  question)
    status_emoji="❓"
    status_color=15844367  # Gold/Yellow
    ;;
  error)
    status_emoji="❌"
    status_color=10038562  # Dark red
    ;;
  *)
    status_emoji="ℹ️"
    status_color=3447003   # Blue
    ;;
esac

# Build message if not provided
if [[ -z "$message" ]]; then
  case "$status" in
    complete)
      if [[ -n "$milestone" ]]; then
        message="Milestone $milestone completed"
      else
        message="Tasks completed"
      fi
      ;;
    blocked)
      message="Work blocked - requires attention"
      ;;
    question)
      message="Question requires your input"
      ;;
    error)
      message="Error encountered"
      ;;
    *)
      message="Status update"
      ;;
  esac
fi

# Play alert sound
play_alert() {
  local sound_override="${LOCAL_NOTIFY_SOUND:-}"
  
  # Use custom sound if provided
  if [[ -n "$sound_override" && -f "$sound_override" ]]; then
    if command -v afplay >/dev/null 2>&1; then
      afplay "$sound_override" && return 0
    elif command -v paplay >/dev/null 2>&1; then
      paplay "$sound_override" && return 0
    fi
  fi

  # Default system sounds based on status
  if command -v afplay >/dev/null 2>&1; then
    case "$status" in
      complete)
        say -v "Samantha" "Agent complete" 2>/dev/null || afplay "/System/Library/Sounds/Hero.aiff"
        ;;
      blocked|error)
        say -v "Samantha" "Agent blocked" 2>/dev/null || afplay "/System/Library/Sounds/Basso.aiff"
        ;;
      question)
        say -v "Samantha" "Agent has a question" 2>/dev/null || afplay "/System/Library/Sounds/Glass.aiff"
        ;;
      *)
        printf '\a'
        ;;
    esac
  elif command -v paplay >/dev/null 2>&1; then
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null || printf '\a'
  elif command -v play >/dev/null 2>&1; then
    play -q -n synth 0.2 sin 880 2>/dev/null || printf '\a'
  else
    printf '\a'
  fi
}

# Play sound if enabled
if [[ ${LOCAL_NOTIFY_DISABLE_SOUND:-0} -ne 1 ]] && [[ $play_sound -eq 1 ]]; then
  play_alert || echo "[local_notify] Failed to play alert sound" >&2
fi

# Get webhook URL
WEBHOOK_URL="${webhook_override:-${LOCAL_NOTIFY_WEBHOOK_URL:-https://discord.com/api/webhooks/1418639192241737748/REDACTED}}"

if [[ -z "$WEBHOOK_URL" ]]; then
  echo "[local_notify] No webhook URL configured; skipping webhook notification." >&2
  echo "[local_notify] $status_emoji [$status] $message"
  [[ -n "$details" ]] && echo "           Details: $details"
  exit 0
fi

# Build Discord embed payload
payload=$(python3 - <<PY
import json, sys

# Build embed fields
fields = [
    {"name": "🖥️ Host", "value": "$HOSTNAME", "inline": True},
    {"name": "📁 Project", "value": "$PROJECT", "inline": True},
    {"name": "🤖 Agent", "value": "$agent_name", "inline": True},
]

if "$milestone":
    fields.append({"name": "🎯 Milestone", "value": "$milestone", "inline": True})

if "$GIT_BRANCH":
    fields.append({"name": "🌿 Branch", "value": "$GIT_BRANCH", "inline": True})

if "$details":
    fields.append({"name": "📋 Details", "value": """$details""", "inline": False})

embed = {
    "title": "$status_emoji $message",
    "color": $status_color,
    "fields": fields,
    "footer": {
        "text": "⏰ $TIMESTAMP"
    },
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}

payload = {
    "embeds": [embed]
}

print(json.dumps(payload))
PY
)

if [[ -z "$payload" ]]; then
  echo "[local_notify] Failed to build payload" >&2
  exit 1
fi

# Send notification
if curl -sS -X POST \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "$WEBHOOK_URL" >/dev/null; then
  echo "[local_notify] $status_emoji Notification sent: [$status] $message"
else
  rc=$?
  echo "[local_notify] Failed to POST notification (exit $rc)." >&2
  exit $rc
fi