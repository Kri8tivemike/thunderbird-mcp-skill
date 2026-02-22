#!/bin/bash
# Thunderbird MCP Skill Wrapper
# Usage: ./thunderbird.sh <command> [args]

THUNDERBIRD_MCP_DIR="${THUNDERBIRD_MCP_DIR:-$HOME/Documents/All Projects/MCP Servers/Thunderbird MCP Server}"

show_help() {
    echo "Thunderbird MCP Skill"
    echo ""
    echo "Commands:"
    echo "  listAccounts         - List all email accounts"
    echo "  listFolders [filter] - List folders, optionally filtered"
    echo "  searchMessages <query> - Search emails"
    echo "  getRecentMessages [days] - Get recent messages"
    echo "  sendMail <to> <subject> <body> - Compose email"
    echo "  listCalendars        - List all calendars"
    echo "  searchContacts <query> - Search contacts"
    echo "  listFilters          - List all filters"
    echo ""
    echo "Environment:"
    echo "  THUNDERBIRD_MCP_DIR - Path to thunderbird-mcp installation"
}

case "${1:-}" in
    listAccounts)
        curl -s -X POST http://localhost:8765 \
            -H "Content-Type: application/json" \
            -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"listAccounts"}}'
        ;;
    listFolders)
        curl -s -X POST http://localhost:8765 \
            -H "Content-Type: application/json" \
            -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"listFolders"}}'
        ;;
    searchMessages)
        QUERY="${2:-}"
        curl -s -X POST http://localhost:8765 \
            -H "Content-Type: application/json" \
            -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"searchMessages\",\"arguments\":{\"query\":\"$QUERY\"}}}"
        ;;
    getRecentMessages)
        DAYS="${2:-7}"
        curl -s -X POST http://localhost:8765 \
            -H "Content-Type: application/json" \
            -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"getRecentMessages\",\"arguments\":{\"days\":$DAYS}}}"
        ;;
    sendMail)
        TO="${2:-}"
        SUBJECT="${3:-}"
        BODY="${4:-}"
        curl -s -X POST http://localhost:8765 \
            -H "Content-Type: application/json" \
            -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"sendMail\",\"arguments\":{\"to\":\"$TO\",\"subject\":\"$SUBJECT\",\"body\":\"$BODY\"}}}"
        ;;
    listCalendars)
        curl -s -X POST http://localhost:8765 \
            -H "Content-Type: application/json" \
            -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"listCalendars"}}'
        ;;
    searchContacts)
        QUERY="${2:-}"
        curl -s -X POST http://localhost:8765 \
            -H "Content-Type: application/json" \
            -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"searchContacts\",\"arguments\":{\"query\":\"$QUERY\"}}}"
        ;;
    listFilters)
        curl -s -X POST http://localhost:8765 \
            -H "Content-Type: application/json" \
            -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"listFilters"}}'
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: ${1:-}"
        show_help
        exit 1
        ;;
esac
