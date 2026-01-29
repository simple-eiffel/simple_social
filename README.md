<p align="center">
  <img src="docs/images/logo.svg" alt="simple_social logo" width="400">
</p>

# simple_social

**[Documentation](https://simple-eiffel.github.io/simple_social/)** | **[GitHub](https://github.com/simple-eiffel/simple_social)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

Social media monitoring and engagement assistant library for Eiffel.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Development** - Core platform APIs and monitoring

## Overview

SIMPLE_SOCIAL provides a SCOOP-powered library for discovering, drafting, and tracking social media opportunities. It helps monitor discussions about Eiffel across multiple platforms, analyze relevance using AI, and draft engagement responses.

This is the **library** - generic, reusable, with no secrets. Your private instance (with API keys and data) lives separately.

## Features

- **Multi-Platform Scout** - Search Reddit, Stack Overflow, HN, GitHub, Dev.to
- **AI-Powered Analyzer** - Relevance scoring and draft generation
- **Engagement Monitor** - Track posted responses for replies
- **Web Dashboard** - Local UI for reviewing opportunities
- **Email Notifier** - Alerts when opportunities arise
- **Design by Contract** - Full preconditions, postconditions, invariants
- **Void Safe** - Fully void-safe implementation
- **SCOOP Compatible** - Concurrent agents for scanning

## Installation

1. Set the ecosystem environment variable (one-time setup for all simple_* libraries):
```bash
export SIMPLE_EIFFEL=D:\prod
```

2. Add to your ECF:
```xml
<library name="simple_social" location="$SIMPLE_EIFFEL/simple_social/simple_social.ecf"/>
```

## Quick Start

### Architecture

```
simple_social/         (this library - public, GitHub)
├── src/
│   ├── core/          Data classes, database, settings
│   ├── platforms/     Reddit, SO, HN, GitHub, Dev.to APIs
│   ├── agents/        SCOOP agents for scanning/analysis
│   ├── web/           Dashboard HTTP handlers
│   └── cli/           Command-line interface

your_instance/         (private - never commit)
├── config/
│   └── settings.json  API keys, SMTP, preferences
├── data/
│   └── social.db      SQLite with your data
└── src/
    └── social_daemon.e  Entry point
```

### Workflow

```
SCOUT → ANALYZE → DRAFT → REVIEW → POST → MONITOR → RESPOND
  ↑                         ↓                           ↓
  └─────────────────────────┴───────────────────────────┘
```

1. **Scout** searches platforms with configured keywords
2. **Analyzer** scores relevance and filters noise
3. **AI generates draft** responses for high-relevance items
4. **Human reviews/edits** drafts in dashboard
5. **Human posts** (copy + click link)
6. **Monitor** watches for replies

## Platforms Supported

| Platform | Search | Monitor | Notes |
|----------|--------|---------|-------|
| Reddit | Yes | Yes | OAuth2 required |
| Stack Overflow | Yes | Yes | Public API |
| Hacker News | Yes | Yes | Algolia API |
| GitHub Discussions | Yes | Yes | Token required |
| Dev.to | Yes | Yes | API key optional |

## API Reference

### Core Classes

| Class | Description |
|-------|-------------|
| `SOCIAL_PLATFORM` | Base class for platform adapters |
| `SOCIAL_OPPORTUNITY` | Discovered discussion to engage with |
| `SOCIAL_DRAFT` | AI-generated response draft |
| `SOCIAL_ENGAGEMENT` | Posted response being monitored |
| `SOCIAL_REPLY` | Reply received on engagement |
| `SOCIAL_DATABASE` | SQLite persistence layer |
| `SOCIAL_SETTINGS` | Configuration management |

### Platform Adapters

| Class | Description |
|-------|-------------|
| `REDDIT_API` | Reddit OAuth2 API client |

### SCOOP Agents

| Class | Description |
|-------|-------------|
| `SOCIAL_SCOUT` | Parallel platform scanning |
| `SOCIAL_ANALYZER` | AI relevance scoring |

## Dependencies

- simple_http (dashboard, API calls)
- simple_ai_client (relevance scoring, drafting)
- simple_sql (SQLite persistence)
- simple_json (API responses)
- simple_datetime (timestamp handling)
- simple_process (daemon support)

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
