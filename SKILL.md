---
name: thunderbird
description: Control Thunderbird email, contacts, calendar, and filters via MCP. Use for reading/searching emails, composing/replying/forwarding, managing folders and filters, searching contacts, and listing calendars. Requires Thunderbird running with the thunderbird-mcp extension.
metadata:
  { "openclaw": { "emoji": "⛈️", "requires": { "anyBins": ["curl", "jq"] } } }
---

# Thunderbird Email Skill

Full email control via the `thunderbird-mcp` extension running inside Thunderbird.

## ⚠️ Prerequisites

- **Thunderbird must be open.** The MCP server only runs when Thunderbird is running.
- If any command fails with "connection refused", Thunderbird is closed. Run: `open -a Thunderbird && sleep 5`
- Check MCP is live: `curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | jq '.result.tools | length'` — should return 19

## How to Call Tools

All tools go through `thunderbird.sh`. It's on the allowlist — no approval needed.

```bash
/Users/kri8tivemike/clawd/skills/thunderbird/thunderbird.sh <command> [args]
```

Or use curl directly for complex payloads (also allowlisted):
```bash
curl -sf -X POST http://localhost:8765 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"TOOL","arguments":{...}}}'
```

---

## Accounts (Live)

| Account ID | Email | Type |
|------------|-------|------|
| `account1` | `Creativemansion91@gmail.com` | IMAP (business) |
| `account4` | `michaeliguariede@gmail.com` | IMAP (personal) |
| `account2` | Local Folders | local |

**Default identity for account1:** `id1` — "CreativeMansion"
**Default identity for account4:** `id2` — "Michael J Iguariede"

---

## Folder Paths (Live)

### account1 — Creativemansion91@gmail.com
| Folder | Path |
|--------|------|
| Inbox | `imap://Creativemansion91%40gmail.com@imap.gmail.com/INBOX` |
| All Mail | `imap://Creativemansion91%40gmail.com@imap.gmail.com/[Gmail]/All Mail` |
| Sent | `imap://Creativemansion91%40gmail.com@imap.gmail.com/[Gmail]/Sent Mail` |
| Drafts | `imap://Creativemansion91%40gmail.com@imap.gmail.com/[Gmail]/Drafts` |
| Spam | `imap://Creativemansion91%40gmail.com@imap.gmail.com/[Gmail]/Spam` |
| Trash | `imap://Creativemansion91%40gmail.com@imap.gmail.com/[Gmail]/Trash` |
| Starred | `imap://Creativemansion91%40gmail.com@imap.gmail.com/[Gmail]/Starred` |
| Important | `imap://Creativemansion91%40gmail.com@imap.gmail.com/[Gmail]/Important` |

### account4 — michaeliguariede@gmail.com
| Folder | Path |
|--------|------|
| Inbox | `imap://michaeliguariede%40gmail.com@imap.gmail.com/INBOX` |
| All Mail | `imap://michaeliguariede%40gmail.com@imap.gmail.com/[Gmail]/All Mail` |
| Sent | `imap://michaeliguariede%40gmail.com@imap.gmail.com/[Gmail]/Sent Mail` |
| Drafts | `imap://michaeliguariede%40gmail.com@imap.gmail.com/[Gmail]/Drafts` |
| Spam | `imap://michaeliguariede%40gmail.com@imap.gmail.com/[Gmail]/Spam` |
| Trash | `imap://michaeliguariede%40gmail.com@imap.gmail.com/[Gmail]/Trash` |

---

## Calendars (Live)

| Calendar ID | Name | Type |
|-------------|------|------|
| `c7f602ac-c7cd-4053-88ef-e8dd5b2d0c25` | michaeliguariede@gmail.com | CalDAV |
| `4e671ea1-e111-4861-ba9b-80becdbf9a25` | Holidays in Nigeria | CalDAV |
| `f6c27660-f0a2-4b20-a696-bbcd966d3866` | Home | local storage |

---

## Tool Reference

### 1. listAccounts
List all email accounts and identities.
```bash
thunderbird.sh listAccounts
```

---

### 2. listFolders
List all folders with message counts. Optionally filter by account.
```bash
# All folders
thunderbird.sh listFolders

# Single account only
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"listFolders","arguments":{"accountId":"account1"}}}'
```

---

### 3. searchMessages
Search by subject, sender, recipient, or body. Returns message IDs and folder paths for use with getMessage.

**Parameters:**
- `query` (required) — text to search. Use `""` to match all.
- `folderPath` — limit to one folder
- `startDate` / `endDate` — ISO 8601 dates
- `maxResults` — default 50, max 200
- `sortOrder` — `"asc"` or `"desc"` (default)

```bash
# Search by keyword
thunderbird.sh searchMessages "invoice"

# Search in specific folder
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"searchMessages","arguments":{"query":"payment","folderPath":"imap://Creativemansion91%40gmail.com@imap.gmail.com/INBOX","maxResults":20}}}'

# Search by date range
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"searchMessages","arguments":{"query":"","startDate":"2026-02-01","endDate":"2026-02-22","maxResults":50}}}'
```

**Response includes:** `messageId`, `folderPath`, `subject`, `author`, `date`, `read` — save these for getMessage/replyToMessage/forwardMessage.

---

### 4. getMessage
Read full email content by ID. Get `messageId` and `folderPath` from searchMessages first.

```bash
thunderbird.sh getMessage "<messageId>"

# With attachment saving
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"getMessage","arguments":{"messageId":"<id>","folderPath":"<path>","saveAttachments":true}}}'
```
Attachments saved to `/tmp/thunderbird-mcp/<messageId>/`

---

### 5. getRecentMessages
Get recent messages without needing to search first.

**Parameters:**
- `folderPath` — defaults to all Inboxes if omitted
- `daysBack` — default 7
- `maxResults` — default 50, max 200
- `unreadOnly` — default false

```bash
# Last 7 days, all inboxes
thunderbird.sh getRecentMessages

# Last 3 days, unread only, CM inbox
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"getRecentMessages","arguments":{"folderPath":"imap://Creativemansion91%40gmail.com@imap.gmail.com/INBOX","daysBack":3,"unreadOnly":true}}}'
```

---

### 6. sendMail
Opens a **pre-filled compose window** in Thunderbird — Michael reviews and clicks Send. Does NOT send silently.

**Parameters:**
- `to` (required), `subject` (required), `body` (required)
- `from` — identity email or ID (e.g. `"Creativemansion91@gmail.com"` or `"id1"`)
- `cc`, `bcc` — comma-separated
- `isHtml` — default false
- `attachments` — array of file paths

```bash
thunderbird.sh sendMail "client@example.com" "Project Update" "Hi, here is the update..."

# From specific account
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d "$(jq -n '{jsonrpc:"2.0",id:1,method:"tools/call",params:{name:"sendMail",arguments:{to:"client@example.com",subject:"Invoice",body:"Please find attached.",from:"Creativemansion91@gmail.com",attachments:["/Users/kri8tivemike/Documents/invoice.pdf"]}}}')"
```

⚠️ **This opens a compose window — Michael must click Send.** Always confirm before calling if Michael hasn't explicitly asked to send.

---

### 7. replyToMessage
Opens a reply compose window. Get `messageId` + `folderPath` from searchMessages.

**Parameters:**
- `messageId` (required), `folderPath` (required), `body` (required)
- `replyAll` — default false
- `to`, `cc`, `bcc`, `from`, `isHtml`, `attachments`

```bash
thunderbird.sh replyToMessage "<messageId>" "Thanks for reaching out. I'll get back to you shortly."

# Reply-all with HTML
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d "$(jq -n --arg id '<messageId>' --arg fp '<folderPath>' '{jsonrpc:"2.0",id:1,method:"tools/call",params:{name:"replyToMessage",arguments:{messageId:$id,folderPath:$fp,body:"<b>Thank you</b>",replyAll:true,isHtml:true}}}')"
```

---

### 8. forwardMessage
Opens a forward compose window.

**Parameters:**
- `messageId` (required), `folderPath` (required), `to` (required)
- `body`, `cc`, `bcc`, `from`, `isHtml`, `attachments`

```bash
thunderbird.sh forwardMessage "<messageId>" "colleague@example.com"
```

---

### 9. updateMessage
Mark read/unread, flag/unflag, move to folder, or trash a message.

**Parameters:**
- `messageId` (required), `folderPath` (required)
- `read` — true/false
- `flagged` — true/false
- `moveTo` — destination folder path
- `trash` — true (cannot combine with moveTo)

```bash
# Mark as read
thunderbird.sh updateMessage "<messageId>" "read" "true"

# Move to folder
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d "$(jq -n --arg id '<messageId>' --arg fp '<folderPath>' '{jsonrpc:"2.0",id:1,method:"tools/call",params:{name:"updateMessage",arguments:{messageId:$id,folderPath:$fp,moveTo:"imap://Creativemansion91%40gmail.com@imap.gmail.com/[Gmail]/Important"}}}')"

# Send to trash
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d "$(jq -n --arg id '<messageId>' --arg fp '<folderPath>' '{jsonrpc:"2.0",id:1,method:"tools/call",params:{name:"updateMessage",arguments:{messageId:$id,folderPath:$fp,trash:true}}}')"
```

---

### 10. deleteMessages
Moves messages to Trash (not permanent).

**Parameters:**
- `messageIds` (required) — array of IDs
- `folderPath` (required)

```bash
thunderbird.sh deleteMessages "<messageId>"

# Multiple messages
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"deleteMessages","arguments":{"messageIds":["id1","id2"],"folderPath":"<path>"}}}'
```

---

### 11. createFolder
Create a subfolder under an existing folder.

**Parameters:**
- `parentFolderPath` (required) — URI from listFolders
- `name` (required)

```bash
thunderbird.sh createFolder "Projects" "imap://Creativemansion91%40gmail.com@imap.gmail.com/INBOX"
```

---

### 12. listFilters
List all filter rules for an account.

```bash
# All accounts
thunderbird.sh listFilters

# Specific account
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"listFilters","arguments":{"accountId":"account1"}}}'
```
Response includes `filterIndex` — needed for updateFilter/deleteFilter/reorderFilters.

---

### 13. createFilter
Create a mail filter rule.

**Parameters:**
- `accountId`, `name`, `conditions` (array), `actions` (array)
- `enabled` — default true
- `type` — bitmask: 1=inbox, 16=manual, 17=both (default)
- `insertAtIndex` — 0 = highest priority

**Condition `attrib` values:** `subject`, `from`, `to`, `cc`, `toOrCc`, `body`, `date`, `size`, `hasAttachment`, `junkStatus`, `tag`
**Condition `op` values:** `contains`, `doesntContain`, `is`, `isnt`, `beginsWith`, `endsWith`, `isGreaterThan`, `isLessThan`
**Action `type` values:** `moveToFolder`, `copyToFolder`, `markRead`, `markUnread`, `markFlagged`, `addTag`, `delete`, `forward`, `stopExecution`

```bash
# Move emails from client to folder
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"createFilter","arguments":{"accountId":"account1","name":"Client Emails","conditions":[{"attrib":"from","op":"contains","value":"@clientdomain.com"}],"actions":[{"type":"moveToFolder","value":"imap://Creativemansion91%40gmail.com@imap.gmail.com/INBOX/Clients"},{"type":"markRead"}]}}}'
```

---

### 14. updateFilter
Modify an existing filter. Get `filterIndex` from listFilters.

```bash
thunderbird.sh updateFilter "<accountId>" "<filterIndex>" "enabled" "false"
```

---

### 15. deleteFilter
Delete a filter by index.

```bash
thunderbird.sh deleteFilter "<accountId>" "<filterIndex>"
```

---

### 16. reorderFilters
Change filter execution priority. Index 0 = highest.

```bash
thunderbird.sh reorderFilters "<accountId>" "<fromIndex>" "<toIndex>"
```

---

### 17. applyFilters
Run all enabled filters on a folder immediately (processes existing messages).

```bash
thunderbird.sh applyFilters "imap://Creativemansion91%40gmail.com@imap.gmail.com/INBOX"

# Must pass accountId + folderPath via curl for this tool
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"applyFilters","arguments":{"accountId":"account1","folderPath":"imap://Creativemansion91%40gmail.com@imap.gmail.com/INBOX"}}}'
```

---

### 18. listCalendars
```bash
thunderbird.sh listCalendars
```
Returns the live calendar list with IDs (see Calendars section above).

---

### 19. createEvent
Opens a **pre-filled event dialog** in Thunderbird — Michael reviews before saving.

**Parameters:**
- `title` (required), `startDate` (required) — ISO 8601
- `endDate` — defaults to start + 1h
- `location`, `description`
- `calendarId` — defaults to first writable (michaeliguariede@gmail.com)
- `allDay` — default false

```bash
thunderbird.sh createEvent "Client Meeting" "2026-02-25T14:00:00" "2026-02-25T15:00:00"

# With location and calendar
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d "$(jq -n '{jsonrpc:"2.0",id:1,method:"tools/call",params:{name:"createEvent",arguments:{title:"Design Review",startDate:"2026-02-25T10:00:00",endDate:"2026-02-25T11:00:00",location:"Zoom",calendarId:"c7f602ac-c7cd-4053-88ef-e8dd5b2d0c25"}}}')"
```

---

### 20. searchContacts
Search contacts from all address books.

```bash
thunderbird.sh searchContacts "John"
```

---

## Common Workflows

### Check unread emails
```bash
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"getRecentMessages","arguments":{"daysBack":1,"unreadOnly":true,"maxResults":20}}}' \
  | python3 -c "import sys,json; msgs=json.loads(json.load(sys.stdin)['result']['content'][0]['text']); [print(m['date'][:10], m['author'][:30], m['subject'][:50]) for m in msgs]"
```

### Search → Read → Reply
```bash
# 1. Find the email
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"searchMessages","arguments":{"query":"website quote","maxResults":5}}}' \
  | python3 -c "import sys,json; r=json.loads(json.load(sys.stdin)['result']['content'][0]['text']); [print(i, m['messageId'], m['folderPath'][:60], m['subject']) for i,m in enumerate(r)]"

# 2. Read it (use messageId + folderPath from step 1)
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"getMessage","arguments":{"messageId":"<id>","folderPath":"<path>"}}}'

# 3. Reply (opens compose window for Michael to review)
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d "$(jq -n --arg id '<id>' --arg fp '<path>' '{jsonrpc:"2.0",id:1,method:"tools/call",params:{name:"replyToMessage",arguments:{messageId:$id,folderPath:$fp,body:"Thanks for reaching out! I will get back to you shortly.\n\n— Michael"}}}')"
```

### Parse JSON output cleanly
```bash
curl -sf -X POST http://localhost:8765 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"listAccounts","arguments":{}}}' \
  | python3 -c "import sys,json; print(json.dumps(json.loads(json.load(sys.stdin)['result']['content'][0]['text']), indent=2))"
```

---

## Rules

1. **Always call listFolders or searchMessages first** before using folder paths — use the live paths above, not guessed ones.
2. **sendMail / replyToMessage / forwardMessage / createEvent open compose windows** — they do NOT send silently. Michael still clicks send. Do not warn him about this repeatedly; it's by design.
3. **deleteMessages moves to Trash**, not permanent deletion. Safe to call without extra confirmation.
4. **updateMessage with trash:true** also moves to Trash, not permanent.
5. **If Thunderbird is closed**, run `open -a Thunderbird && sleep 5` then retry.
6. **thunderbird.sh is on the exec allowlist** — no approval prompts.
7. **For multi-step workflows** (search → read → reply), always do them in sequence and report each step to Michael.
