# S06: BOUNDARIES
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## System Boundaries

```
┌────────────────────────────────────────────────────────────┐
│                     simple_social                           │
│  ┌────────────────────────────────────────────────────┐   │
│  │                  SOCIAL_CLI                         │   │
│  │              (user commands)                        │   │
│  └────────────────────────────────────────────────────┘   │
│         │                              │                   │
│         ▼                              ▼                   │
│  ┌────────────────┐          ┌────────────────────────┐  │
│  │ SOCIAL_SCOUT   │          │   SOCIAL_DATABASE      │  │
│  │ (scanner)      │          │   (persistence)        │  │
│  └────────────────┘          └────────────────────────┘  │
│         │                              │                   │
│         ▼                              ▼                   │
│  ┌────────────────┐          ┌────────────────────────┐  │
│  │ Platform APIs  │          │   Entity Classes       │  │
│  │ (Reddit, etc.) │          │   (Opp, Draft, etc.)   │  │
│  └────────────────┘          └────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
         │                              │
         ▼                              ▼
   ┌──────────────┐            ┌────────────────┐
   │  External    │            │   SQLite DB    │
   │  APIs        │            │   (social.db)  │
   │  (HTTP)      │            │                │
   └──────────────┘            └────────────────┘
```

## Entity Relationships

```
┌─────────────────┐
│   Opportunity   │
│ (discovered)    │
└────────┬────────┘
         │ 1:N
         ▼
┌─────────────────┐
│     Draft       │
│ (response)      │
└────────┬────────┘
         │ 1:1
         ▼
┌─────────────────┐
│   Engagement    │
│ (posted)        │
└────────┬────────┘
         │ 1:N
         ▼
┌─────────────────┐
│     Reply       │
│ (community)     │
└─────────────────┘
```

## Data Flow

1. **Scan**: Scout -> Platform API -> Opportunities -> Database
2. **Draft**: User -> Draft Creation -> Database
3. **Post**: User -> Manual Post -> Engagement -> Database
4. **Monitor**: Scout -> Check Engagement -> Replies -> Database
