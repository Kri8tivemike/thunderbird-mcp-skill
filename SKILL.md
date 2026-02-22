# Thunderbird Email Skill

Control Thunderbird email, contacts, and calendar via MCP protocol.

## Description

This skill integrates with Thunderbird (desktop email client) through the thunderbird-mcp extension. It enables AI assistants to access email, manage contacts, and interact with calendars using the Model Context Protocol (MCP).

## Prerequisites

- **Thunderbird 102+** installed on macOS
- **thunderbird-mcp.xpi** extension loaded in Thunderbird
- Node.js (for the MCP bridge if needed)

### Installing the Extension

1. Open Thunderbird → Add-ons and Themes
2. Debug Add-ons → Load `extension` directory from thunderbird-mcp
3. Or install the pre-built XPI: `dist/thunderbird-mcp.xpi`
4. Restart Thunderbird
5. The extension starts MCP server on `http://localhost:8765`

## Commands

### Email Management

| Command | Description |
|---------|-------------|
| `listAccounts` | List all email accounts and identities |
| `listFolders` | Browse folder tree with message counts |
| `searchMessages` | Find emails by subject, sender, recipient, date, folder |
| `getMessage` | Read full email content, save attachments |
| `getRecentMessages` | Get recent messages with date/unread filtering |
| `updateMessage` | Mark read/unread, flag/unflag, move, trash |
| `deleteMessages` | Delete messages (moves to Trash) |
| `createFolder` | Create new subfolders for organization |

### Composing

| Command | Description |
|---------|-------------|
| `sendMail` | Compose and send email (opens review window) |
| `replyToMessage` | Reply with quoted original, proper threading |
| `forwardMessage` | Forward with attachments preserved |

### Filters

| Command | Description |
|---------|-------------|
| `listFilters` | List all filter rules |
| `createFilter` | Create filters with conditions/actions |
| `updateFilter` | Modify filter settings |
| `deleteFilter` | Remove a filter |
| `reorderFilters` | Change filter priority |
| `applyFilters` | Run filters on a folder on demand |

### Calendar & Contacts

| Command | Description |
|---------|-------------|
| `listCalendars` | List all calendars (local + CalDAV) |
| `createEvent` | Open pre-filled calendar event dialog |
| `searchContacts` | Look up contacts from address books |

## Usage Examples

```bash
# List all email accounts
thunderbird listAccounts

# Search for unread emails from specific sender
thunderbird searchMessages --unread true --from "client@example.com"

# Get recent messages from last 7 days
thunderbird getRecentMessages --days 7

# Create a new folder for organizing
thunderbird createFolder --name "Projects" --parent "Inbox"

# Search contacts
thunderbird searchContacts --query "John"

# List all calendars
thunderbird listCalendars
```

## Configuration

### OpenClaw MCP Config

Add to your `~/.config/openclaw/mcp.json`:

```json
{
  "mcpServers": {
    "thunderbird": {
      "command": "node",
      "args": ["/path/to/thunderbird-mcp/mcp-bridge.cjs"]
    }
  }
}
```

Or connect directly via HTTP (if bridge not needed):

```json
{
  "mcpServers": {
    "thunderbird-http": {
      "url": "http://localhost:8765"
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

- GitHub: https://github.com/Kri8tivemike/thunderbird-mcp
- Original: https://github.com/TKasperczyk/thunderbird-mcp
