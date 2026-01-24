# S02: CLASS CATALOG
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Class Hierarchy

```
SIMPLE_SQL_DATABASE
└── SOCIAL_DATABASE (extended with domain operations)

ANY
├── SOCIAL_OPPORTUNITY (discovered post)
├── SOCIAL_DRAFT (response content)
├── SOCIAL_ENGAGEMENT (posted response)
├── SOCIAL_REPLY (community reply)
├── SOCIAL_SETTINGS (configuration)
├── SOCIAL_PLATFORM (constants)
├── SOCIAL_SCOUT (scanner agent)
├── SOCIAL_ANALYZER (relevance scoring)
├── SOCIAL_CLI (command line)
├── SOCIAL_DASHBOARD (web UI)
└── REDDIT_API (platform client)
```

## Entity Classes

### SOCIAL_OPPORTUNITY
**Purpose**: Represents a discovered post/discussion
**Attributes**: id, platform, url, title, snippet, relevance_score, status, discovered_at, last_checked
**Status Values**: 0=New, 1=Reviewed, 2=Drafted, 3=Posted, 4=Archived

### SOCIAL_DRAFT
**Purpose**: Response content for an opportunity
**Attributes**: id, opportunity_id, content, original_content, status, created_at, modified_at, generation_count
**Status Values**: 0=Generated, 1=Edited, 2=Approved, 3=Rejected

### SOCIAL_ENGAGEMENT
**Purpose**: Tracks a posted response
**Attributes**: id, opportunity_id, draft_id, post_url, reply_count, unread_replies, posted_at, last_checked, is_active

### SOCIAL_REPLY
**Purpose**: Community reply to engagement
**Attributes**: id, engagement_id, reply_url, author, content, is_read, needs_response, discovered_at

## Infrastructure Classes

### SOCIAL_DATABASE
**Purpose**: SQLite persistence layer
**Features**: CRUD for all entities, statistics, resource management

### SOCIAL_PLATFORM
**Purpose**: Platform identifiers and metadata
**Constants**: Reddit=1, Stack_overflow=2, Hacker_news=3, Github_discussions=4, Devto=5
