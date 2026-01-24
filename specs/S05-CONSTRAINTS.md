# S05: CONSTRAINTS
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Technical Constraints

### Database
- SQLite single-file storage
- Auto-schema creation on open
- Foreign keys defined but not enforced
- TEXT for timestamps (ISO 8601 format)

### Platform APIs
- Reddit: OAuth2 required
- Stack Exchange: API key recommended
- Hacker News: No auth (rate limited)
- GitHub: Token recommended
- Dev.to: API key required

### Data Types
- URLs: TEXT, max reasonable length
- Content: TEXT, no explicit limit
- Scores: REAL (0.0 to 1.0 typically)
- Counts: INTEGER

## Design Constraints

### Entity Lifecycle
- Opportunity -> Draft -> Engagement -> Reply
- One-to-many relationships
- Soft delete via status (no actual delete)

### Scanning Behavior
- Keyword-based search
- Per-subreddit Reddit scanning
- Deduplication by URL

### Human-in-the-Loop
- No automated posting
- Draft review required
- Manual approval workflow

## Operational Constraints

### Platform Limits
- Reddit: 60 requests/minute
- Stack Exchange: 300/day (without key)
- Hacker News: Best-effort
- API keys stored in config file

### Storage
- Database grows with discovered content
- No automatic pruning
- Manual archival needed
