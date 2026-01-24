# 7S-04: SIMPLE-STAR ECOSYSTEM
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Ecosystem Dependencies

### Uses (Dependencies)
- **simple_sql** - SQLite database (SIMPLE_SQL_DATABASE)
- **simple_http** - HTTP client for APIs
- **simple_json** - JSON parsing
- **EiffelBase** - Standard library

### Used By (Dependents)
- None (standalone application)

## Integration Points

### Database Usage
```eiffel
create database.make ("social.db")
database.insert_opportunity (opportunity)
opportunities := database.actionable_opportunities
```

### Platform API Pattern
```eiffel
create reddit_api.make (settings)
results := reddit_api.search_subreddits (subreddits, keyword, limit)
```

### Entity Creation
```eiffel
create opportunity.make (platform, url, title, snippet)
opportunity.set_relevance_score (0.85)
```

## Ecosystem Role

simple_social is a **domain-specific application** for social media monitoring - it's a vertical solution built on the simple_* foundation.
