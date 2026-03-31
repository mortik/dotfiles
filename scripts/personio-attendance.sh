#!/usr/bin/env bash

set -eu

# Personio Attendance Script
# Adds working hours for weekdays in a given month via Personio v2 API
#
# Usage:
#   ./scripts/personio-attendance.sh              # current month
#   ./scripts/personio-attendance.sh 2026-03       # specific month
#   ./scripts/personio-attendance.sh 2026-03-31    # specific date
#
# Credentials are read from 1Password:
#   op://Private/Personio API/client_id
#   op://Private/Personio API/client_secret
#
# Or from environment variables:
#   PERSONIO_CLIENT_ID, PERSONIO_CLIENT_SECRET

PERSONIO_API="https://api.personio.de"
EMPLOYEE_ID="18057412"

# Working hours config
START_TIME="09:00"
END_TIME="17:30"
BREAK_START="12:00"
BREAK_END="12:30"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# --- Credentials ---

get_credentials() {
  if [ -n "${PERSONIO_CLIENT_ID:-}" ] && [ -n "${PERSONIO_CLIENT_SECRET:-}" ]; then
    CLIENT_ID="$PERSONIO_CLIENT_ID"
    CLIENT_SECRET="$PERSONIO_CLIENT_SECRET"
  elif command -v op &>/dev/null; then
    CLIENT_ID=$(op read "op://Private/Personio API/client_id" 2>/dev/null) || error "Failed to read client_id from 1Password"
    CLIENT_SECRET=$(op read "op://Private/Personio API/client_secret" 2>/dev/null) || error "Failed to read client_secret from 1Password"
  else
    error "No credentials found. Set PERSONIO_CLIENT_ID/PERSONIO_CLIENT_SECRET or install 1Password CLI."
  fi
}

# --- Auth ---

get_token() {
  local response
  response=$(curl -s -X POST "$PERSONIO_API/v2/auth/token" \
    -H "Content-Type: application/json" \
    -d "{\"client_id\": \"$CLIENT_ID\", \"client_secret\": \"$CLIENT_SECRET\"}")

  TOKEN=$(echo "$response" | jq -r '.data.token // empty')
  if [ -z "$TOKEN" ]; then
    error "Authentication failed: $(echo "$response" | jq -r '.error.message // .message // "unknown error"')"
  fi
  log "Authenticated with Personio API"
}

# --- Date helpers ---

is_weekday() {
  local day_of_week
  day_of_week=$(date -j -f "%Y-%m-%d" "$1" "+%u" 2>/dev/null || date -d "$1" "+%u")
  [ "$day_of_week" -le 5 ]
}

days_in_month() {
  local year=$1 month=$2
  date -j -f "%Y-%m-%d" "$year-$month-01" "+%m" &>/dev/null && \
    date -j -v1d -v+"$month"m -v-1d -f "%Y-%m-%d" "$year-01-01" "+%d" 2>/dev/null || \
    date -d "$year-$month-01 +1 month -1 day" "+%d"
}

last_day_of_month() {
  local year=$1 month=$2
  # macOS compatible
  if date -j -f "%Y-%m-%d" "$year-$month-01" "+%Y-%m-%d" &>/dev/null; then
    date -j -v1d -v"${month}m" -v"${year}y" -v+1m -v-1d "+%d"
  else
    date -d "$year-$month-01 +1 month -1 day" "+%d"
  fi
}

get_dates() {
  local input="${1:-}"
  local dates=()

  if [ -z "$input" ]; then
    # Current month
    local year month
    year=$(date "+%Y")
    month=$(date "+%m")
    input="$year-$month"
  fi

  if [[ "$input" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    # Single date
    dates+=("$input")
  elif [[ "$input" =~ ^[0-9]{4}-[0-9]{2}$ ]]; then
    # Full month
    local year="${input%-*}"
    local month="${input#*-}"
    local last_day
    last_day=$(last_day_of_month "$year" "$month")

    for day in $(seq 1 "$last_day"); do
      local date_str
      date_str=$(printf "%s-%s-%02d" "$year" "$month" "$day")
      dates+=("$date_str")
    done
  else
    error "Invalid date format. Use YYYY-MM or YYYY-MM-DD"
  fi

  echo "${dates[@]}"
}

# --- API calls ---

create_attendance() {
  local date=$1 type=$2 start=$3 end=$4 comment="${5:-}"

  local body
  body=$(jq -n \
    --arg person_id "$EMPLOYEE_ID" \
    --arg type "$type" \
    --arg start "${date}T${start}:00" \
    --arg end "${date}T${end}:00" \
    --arg comment "$comment" \
    '{
      person: {id: $person_id},
      type: $type,
      start: {date_time: $start},
      end: {date_time: $end},
      comment: (if $comment != "" then $comment else null end)
    }')

  local response http_code
  response=$(curl -s -w "\n%{http_code}" -X POST "$PERSONIO_API/v2/attendance-periods" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$body")

  http_code=$(echo "$response" | tail -1)
  local response_body
  response_body=$(echo "$response" | sed '$d')

  if [ "$http_code" = "201" ]; then
    return 0
  else
    local error_msg
    error_msg=$(echo "$response_body" | jq -r '.error.message // .message // "unknown error"' 2>/dev/null || echo "$response_body")
    echo "$error_msg"
    return 1
  fi
}

check_existing_attendance() {
  local date=$1
  local response
  response=$(curl -s "$PERSONIO_API/v1/company/attendances?start_date=$date&end_date=$date&employees[]=$EMPLOYEE_ID" \
    -H "Authorization: Bearer $TOKEN")

  local count
  count=$(echo "$response" | jq '.data | length' 2>/dev/null || echo "0")
  [ "$count" -gt 0 ]
}

# --- Main ---

main() {
  echo
  echo "Personio Attendance Tracker"
  echo "==========================="
  echo

  get_credentials
  get_token

  local dates
  read -ra dates <<< "$(get_dates "${1:-}")"

  local created=0 skipped=0 failed=0

  for date in "${dates[@]}"; do
    if ! is_weekday "$date"; then
      continue
    fi

    # Check for existing attendance
    if check_existing_attendance "$date"; then
      warn "$date - already has attendance, skipping"
      skipped=$((skipped + 1))
      continue
    fi

    # Create WORK period
    local work_error
    if work_error=$(create_attendance "$date" "WORK" "$START_TIME" "$END_TIME"); then
      # Create BREAK period
      if break_error=$(create_attendance "$date" "BREAK" "$BREAK_START" "$BREAK_END"); then
        log "$date - ${START_TIME}-${END_TIME} (break ${BREAK_START}-${BREAK_END})"
        created=$((created + 1))
      else
        warn "$date - work added but break failed: $break_error"
        created=$((created + 1))
      fi
    else
      echo -e "${RED}[✗]${NC} $date - failed: $work_error"
      failed=$((failed + 1))
    fi
  done

  echo
  echo "Done: ${created} created, ${skipped} skipped, ${failed} failed"
  echo
}

main "$@"
