#!/usr/bin/env bash

# Read JWT from stdin.
read -r JWT

# Remove newline characters and trailing spaces
CLEAN_JWT=$(printf '%s' "$JWT" | tr -d '\n' | sed 's/ *$//')

# Split the JWT string into its 3 parts using a dot as the delimiter
declare -r IFS='.'
read -ra PARTS <<< "$CLEAN_JWT"

# Decode the first and second parts of the JWT using base64
# HEADER="$(printf "%s" "${PARTS[0]}" | base64 -d 2>/dev/null)"
# PAYLOAD="$(printf "%s" "${PARTS[1]}" | base64 -d 2>/dev/null)"

# Decode the first and second parts of the JWT using base64
HEADER=$(base64 -d <<< "${PARTS[0]}" 2>/dev/null)
PAYLOAD=$(base64 -d <<< "${PARTS[1]}" 2>/dev/null)

# Print the decoded header and payload
printf "Header:\n%s\n\n" "$(jq <<< "$HEADER")"
printf "Payload:\n%s\n\n" "$(jq <<< "$PAYLOAD")"

