# S01: PROJECT INVENTORY
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Project Structure

```
simple_social/
├── src/
│   ├── core/
│   │   ├── social_opportunity.e     # Discovered posts
│   │   ├── social_draft.e           # Response drafts
│   │   ├── social_engagement.e      # Posted responses
│   │   ├── social_reply.e           # Community replies
│   │   ├── social_database.e        # SQLite persistence
│   │   ├── social_settings.e        # Configuration
│   │   └── social_platform.e        # Platform constants
│   ├── agents/
│   │   ├── social_scout.e           # Background scanner
│   │   └── social_analyzer.e        # Relevance scoring
│   ├── platforms/
│   │   └── reddit_api.e             # Reddit client
│   ├── cli/
│   │   └── social_cli.e             # Command line
│   └── web/
│       └── social_dashboard.e       # Web UI
├── testing/
│   ├── test_app.e
│   └── lib_tests.e
├── research/
├── specs/
└── simple_social.ecf
```

## Source Files

| File | Type | Lines | Purpose |
|------|------|-------|---------|
| social_opportunity.e | Entity | ~100 | Discovered post |
| social_draft.e | Entity | ~80 | Response content |
| social_engagement.e | Entity | ~70 | Posted response |
| social_reply.e | Entity | ~60 | Reply tracking |
| social_database.e | Repository | 600 | CRUD operations |
| social_scout.e | Agent | 119 | Background scanner |
| social_platform.e | Constants | 76 | Platform IDs |

## Dependencies

- simple_sql, simple_http, simple_json
