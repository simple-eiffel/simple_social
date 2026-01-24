# 7S-02: STANDARDS
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Applicable Standards

### Platform APIs
- **Reddit API**: OAuth2 authentication, JSON responses
- **Stack Exchange API**: API key authentication
- **Hacker News API**: Firebase-based, no auth
- **GitHub API**: REST v3, GraphQL v4
- **Dev.to API**: API key authentication

### Data Standards
- **SQLite**: Relational storage
- **JSON**: API communication
- **UTC Timestamps**: Cross-timezone consistency

## Design Patterns

1. **Agent Pattern**: SOCIAL_SCOUT for async scanning
2. **Repository Pattern**: SOCIAL_DATABASE for persistence
3. **Entity Pattern**: Opportunity, Draft, Engagement, Reply
4. **Factory Pattern**: Creating opportunities from API responses

## Entity Model

```
Opportunity (discovered post)
    │
    └── Draft (response content)
            │
            └── Engagement (posted response)
                    │
                    └── Reply (community replies)
```

## Status Codes

### Opportunity Status
- 0: New
- 1: Reviewed
- 2: Drafted
- 3: Posted
- 4: Archived

### Draft Status
- 0: Generated
- 1: Edited
- 2: Approved
- 3: Rejected
