# S07: SPECIFICATION SUMMARY
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## One-Line Description

Social media monitoring system for discovering engagement opportunities and tracking responses across developer platforms.

## Key Specifications

| Aspect | Specification |
|--------|---------------|
| **Type** | Domain Application |
| **Storage** | SQLite |
| **Platforms** | Reddit, Stack Overflow, HN, GitHub, Dev.to |
| **Entities** | Opportunity, Draft, Engagement, Reply |
| **Workflow** | Human-in-the-loop (no auto-posting) |

## Platform Constants

| Platform | ID | Implementation |
|----------|-----|----------------|
| Reddit | 1 | Partial |
| Stack Overflow | 2 | Stub |
| Hacker News | 3 | Stub |
| GitHub Discussions | 4 | Stub |
| Dev.to | 5 | Stub |

## Entity Status Codes

### Opportunity
| Status | Meaning |
|--------|---------|
| 0 | New |
| 1 | Reviewed |
| 2 | Drafted |
| 3 | Posted |
| 4 | Archived |

### Draft
| Status | Meaning |
|--------|---------|
| 0 | Generated |
| 1 | Edited |
| 2 | Approved |
| 3 | Rejected |

## Critical Invariants

1. Opportunities are unique by URL
2. Drafts belong to exactly one opportunity
3. Engagements link draft to posted response
4. Replies track community responses to engagements
