---
name: thunderbird
description: Control Thunderbird email, contacts, calendar, and filters via MCP. Use for reading/searching emails, composing/replying/forwarding, managing folders and filters, searching contacts, and listing calendars. Requires Thunderbird running with the thunderbird-mcp extension.
metadata:
  { "openclaw": { "emoji": "⛈️", "requires": { "anyBins": ["curl", "jq"] } } }
---

# Thunderbird Email Skill

Control Thunderbird email, contacts, and calendar via MCP protocol.

## How It Works

This skill talks to the `thunderbird-mcp` extension running inside Thunderbird. The extension starts a local MCP server on `http://localhost:8765`. The `thunderbird.sh` wrapper sends JSON-RPC requests to it.

**Thunderbird must be open** for any command to work.

## Prerequisites

- **Thunderbird 102+** installed on macOS
- **thunderbird-mcp extension** loaded in Thunderbird
- `curl` and `jq` installed (both available via Homebrew)

### Installing the Extension

1. Clone the extension: `git clone https://github.com/Kri8tivemike/thunderbird-mcp`
2. Open Thunderbird → Add-ons and Themes → Debug Add-ons
3. Click "Load Temporary Add-on" → select `manifest.json` from the cloned folder
4. Or install the pre-built XPI: `dist/thunderbird-mcp.xpi`
5. Restart Thunderbird — MCP server starts on `http://localhost:8765`

## Commands

### Email Management

| Command | Description |
|---------|-------------|
| `listAccounts` | List all email accounts and identities |
| `listFolders` | Browse folder tree with message counts |
| `searchMessages <query>` | Find emails by subject, sender, recipient, date, folder |
| `getMessage <id>` | Read full email content |
| `getRecentMessages [days]` | Get recent messages (default: 7 days) |
| `updateMessage <id> <field> <value>` | Mark read/unread, flag/unflag, move, trash |
| `deleteMessages <id>` | Delete message (moves to Trash) |
| `createFolder <name> [parent]` | Create new subfolder |

### Composing

| Command | Description |
|---------|-------------|
| `sendMail <to> <subject> <body>` | Compose and send email |
| `replyToMessage <id> <body>` | Reply with quoted original |
| `forwardMessage <id> <to>` | Forward with attachments preserved |

### Filters

| Command | Description |
|---------|-------------|
| `listFilters` | List all filter rules |
| `createFilter <name> <conditions> <actions>` | Create filter |
| `updateFilter <id> <field> <value>` | Modify filter |
| `deleteFilter <id>` | Remove a filter |
| `reorderFilters <id> <position>` | Change filter priority |
| `applyFilters <folder>` | Run filters on a folder on demand |

### Calendar & Contacts

| Command | Description |
|---------|-------------|
| `listCalendars` | List all calendars (local + CalDAV) |
| `createEvent <title> <start> <end>` | Open pre-filled calendar event dialog |
| `searchContacts <query>` | Look up contacts from address books |

## Usage Examples

```bash
# List all email accounts
thunderbird.sh listAccounts

# Search for unread emails
thunderbird.sh searchMessages "invoice"

# Get recent messages from last 7 days
thunderbird.sh getRecentMessages 7

# Read a specific message
thunderbird.sh getMessage msg123

# Reply to a message
thunderbird.sh replyToMessage msg123 "Thanks for the update!"

# Forward a message
thunderbird.sh forwardMessage msg123 "colleague@example.com"

# Create a new folder
thunderbird.sh createFolder "Projects" "Inbox"

# Search contacts
thunderbird.sh searchContacts "John"

# List all calendars
thunderbird.sh listCalendars

# List filters
thunderbird.sh listFilters
```

## Configuration

### OpenClaw MCP Config

Add to your `~/.openclaw/openclaw.json` under the top-level `"mcp"` key:

```json
{
  "mcp": {
    "servers": {
      "thunderbird": {
        "url": "http://localhost:8765"
      }
    }
  }
}
```

## Security

- MCP server runs on **localhost:8765 only**
- No remote access possible
- Compose tools open review windows before sending
- Nothing is sent without your approval

## Source

- Skill repo: https://github.com/Kri8tivemike/thunderbird-mcp-skill
- Extension fork: https://github.com/Kri8tivemike/thunderbird-mcp
- Original extension: https://github.com/TKasperczyk/thunderbird-mcp
