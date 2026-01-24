# 7S-06: SIZING
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Current Size

### Source Files
- **Core Classes**: 6 entity/domain classes
- **Agent Classes**: 2 (scout, analyzer)
- **Platform Classes**: 1 (Reddit API)
- **Infrastructure**: 3 (database, settings, CLI)
- **Web**: 1 (dashboard)
- **Total Lines**: ~1200+ lines of Eiffel

### Directory Structure
| Directory | Files | Purpose |
|-----------|-------|---------|
| src/core | 6 | Domain entities |
| src/agents | 2 | Background workers |
| src/platforms | 1 | API clients |
| src/cli | 1 | Command line |
| src/web | 1 | Dashboard |
| testing | 2 | Test suite |

### Database Schema
| Table | Purpose |
|-------|---------|
| opportunities | Discovered posts |
| drafts | Response drafts |
| engagements | Posted responses |
| replies | Community replies |
| keywords | Search terms |
| resources | Curated content |
| resource_tags | Tag associations |

## Complexity Assessment

- **Tables**: 7
- **Indexes**: 7
- **Entity Types**: 4 (Opportunity, Draft, Engagement, Reply)
- **Platform Support**: 5 (Reddit implemented, others stubbed)

## Growth Projections

- More platform implementations
- Enhanced analytics
- AI integration for draft generation
- Browser extension for manual capture
