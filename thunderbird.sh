#!/bin/bash
# Thunderbird MCP Skill Wrapper
# Requires: curl, jq
# Thunderbird must be running with the thunderbird-mcp extension active.

MCP_URL="${THUNDERBIRD_MCP_URL:-http://localhost:8765}"

mcp_call() {
    local method="$1"
    local args_json="${2:-{}}"
    jq -n \
        --arg method "$method" \
        --argjson args "$args_json" \
        '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":$method,"arguments":$args}}' \
    | curl -sf -X POST "$MCP_URL" \
        -H "Content-Type: application/json" \
        -d @-
}

show_help() {
    cat <<EOF
Thunderbird MCP Skill — requires Thunderbird + thunderbird-mcp extension running

Email Management:
  listAccounts                           List all email accounts
  listFolders                            List all folders with message counts
  searchMessages <query>                 Search emails by any field
  getMessage <id>                        Read full email content
  getRecentMessages [days]               Recent messages (default: 7 days)
  updateMessage <id> <field> <value>     Update message (read, flagged, folder...)
  deleteMessages <id>                    Move message to Trash
  createFolder <name> [parent]           Create a new folder

Composing:
  sendMail <to> <subject> <body>         Compose and send email
  replyToMessage <id> <body>             Reply with quoted original
  forwardMessage <id> <to>              Forward message

Filters:
  listFilters                            List all filter rules
  createFilter <name> <cond_json> <actions_json>   Create filter
  updateFilter <id> <field> <value>      Modify filter
  deleteFilter <id>                      Remove filter
  reorderFilters <id> <position>         Change filter priority
  applyFilters <folder>                  Run filters on folder now

Calendar & Contacts:
  listCalendars                          List all calendars
  createEvent <title> <start> <end>      Open pre-filled event dialog
  searchContacts <query>                 Search contacts

Environment:
  THUNDERBIRD_MCP_URL   MCP server URL (default: http://localhost:8765)
EOF
}

case "${1:-}" in
    # ── Email Management ─────────────────────────────────────────────────────
    listAccounts)
        mcp_call "listAccounts"
        ;;
    listFolders)
        mcp_call "listFolders"
        ;;
    searchMessages)
        mcp_call "searchMessages" "$(jq -n --arg q "${2:?Usage: searchMessages <query>}" '{"query":$q}')"
        ;;
    getMessage)
        mcp_call "getMessage" "$(jq -n --arg id "${2:?Usage: getMessage <id>}" '{"id":$id}')"
        ;;
    getRecentMessages)
        days="${2:-7}"
        mcp_call "getRecentMessages" "$(jq -n --argjson d "$days" '{"days":$d}')"
        ;;
    updateMessage)
        mcp_call "updateMessage" "$(jq -n \
            --arg id    "${2:?Usage: updateMessage <id> <field> <value>}" \
            --arg field "${3:?Usage: updateMessage <id> <field> <value>}" \
            --arg val   "${4:?Usage: updateMessage <id> <field> <value>}" \
            '{"id":$id,"field":$field,"value":$val}')"
        ;;
    deleteMessages)
        mcp_call "deleteMessages" "$(jq -n --arg id "${2:?Usage: deleteMessages <id>}" '{"id":$id}')"
        ;;
    createFolder)
        args="$(jq -n --arg name "${2:?Usage: createFolder <name> [parent]}" --arg parent "${3:-}" \
            'if $parent != "" then {"name":$name,"parent":$parent} else {"name":$name} end')"
        mcp_call "createFolder" "$args"
        ;;

    # ── Composing ────────────────────────────────────────────────────────────
    sendMail)
        mcp_call "sendMail" "$(jq -n \
            --arg to      "${2:?Usage: sendMail <to> <subject> <body>}" \
            --arg subject "${3:?Usage: sendMail <to> <subject> <body>}" \
            --arg body    "${4:?Usage: sendMail <to> <subject> <body>}" \
            '{"to":$to,"subject":$subject,"body":$body}')"
        ;;
    replyToMessage)
        mcp_call "replyToMessage" "$(jq -n \
            --arg id   "${2:?Usage: replyToMessage <id> <body>}" \
            --arg body "${3:?Usage: replyToMessage <id> <body>}" \
            '{"id":$id,"body":$body}')"
        ;;
    forwardMessage)
        mcp_call "forwardMessage" "$(jq -n \
            --arg id "${2:?Usage: forwardMessage <id> <to>}" \
            --arg to "${3:?Usage: forwardMessage <id> <to>}" \
            '{"id":$id,"to":$to}')"
        ;;

    # ── Filters ──────────────────────────────────────────────────────────────
    listFilters)
        mcp_call "listFilters"
        ;;
    createFilter)
        mcp_call "createFilter" "$(jq -n \
            --arg name        "${2:?Usage: createFilter <name> <cond_json> <actions_json>}" \
            --argjson cond    "${3:?Usage: createFilter <name> <cond_json> <actions_json>}" \
            --argjson actions "${4:?Usage: createFilter <name> <cond_json> <actions_json>}" \
            '{"name":$name,"conditions":$cond,"actions":$actions}')"
        ;;
    updateFilter)
        mcp_call "updateFilter" "$(jq -n \
            --arg id    "${2:?Usage: updateFilter <id> <field> <value>}" \
            --arg field "${3:?Usage: updateFilter <id> <field> <value>}" \
            --arg val   "${4:?Usage: updateFilter <id> <field> <value>}" \
            '{"id":$id,"field":$field,"value":$val}')"
        ;;
    deleteFilter)
        mcp_call "deleteFilter" "$(jq -n --arg id "${2:?Usage: deleteFilter <id>}" '{"id":$id}')"
        ;;
    reorderFilters)
        mcp_call "reorderFilters" "$(jq -n \
            --arg id   "${2:?Usage: reorderFilters <id> <position>}" \
            --argjson pos "${3:?Usage: reorderFilters <id> <position>}" \
            '{"id":$id,"position":$pos}')"
        ;;
    applyFilters)
        mcp_call "applyFilters" "$(jq -n --arg folder "${2:?Usage: applyFilters <folder>}" '{"folder":$folder}')"
        ;;

    # ── Calendar & Contacts ──────────────────────────────────────────────────
    listCalendars)
        mcp_call "listCalendars"
        ;;
    createEvent)
        mcp_call "createEvent" "$(jq -n \
            --arg title "${2:?Usage: createEvent <title> <start> <end>}" \
            --arg start "${3:?Usage: createEvent <title> <start> <end>}" \
            --arg end   "${4:?Usage: createEvent <title> <start> <end>}" \
            '{"title":$title,"start":$start,"end":$end}')"
        ;;
    searchContacts)
        mcp_call "searchContacts" "$(jq -n --arg q "${2:?Usage: searchContacts <query>}" '{"query":$q}')"
        ;;

    # ── Help / unknown ───────────────────────────────────────────────────────
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: ${1:-<none>}" >&2
        show_help >&2
        exit 1
        ;;
esac
