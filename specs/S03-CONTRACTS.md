# S03: CONTRACTS
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## Design by Contract Summary

### SOCIAL_DATABASE Contracts

```eiffel
make (a_path: READABLE_STRING_GENERAL)
    require
        path_not_empty: not a_path.is_empty

insert_opportunity (a_opp: SOCIAL_OPPORTUNITY): INTEGER
    require
        not_persisted: a_opp.id = 0
    ensure
        has_id: Result > 0 implies a_opp.id = Result

update_opportunity (a_opp: SOCIAL_OPPORTUNITY)
    require
        is_persisted: a_opp.id > 0

drafts_for_opportunity (a_opp_id: INTEGER): ARRAYED_LIST [SOCIAL_DRAFT]
    require
        valid_id: a_opp_id > 0

replies_for_engagement (a_eng_id: INTEGER): ARRAYED_LIST [SOCIAL_REPLY]
    require
        valid_id: a_eng_id > 0

recent_opportunities (a_limit: INTEGER): ARRAYED_LIST [SOCIAL_OPPORTUNITY]
    require
        positive_limit: a_limit > 0
```

### SOCIAL_PLATFORM Contracts

```eiffel
name (a_platform: INTEGER): STRING_8
    require
        valid_platform: is_valid (a_platform)
    ensure
        result_not_empty: not Result.is_empty

is_valid (a_platform: INTEGER): BOOLEAN
    -- Returns True if platform in valid range (1-5)

all_platforms: ARRAYED_LIST [INTEGER]
    once
    ensure
        result_attached: Result /= Void
        has_all: Result.count = 5
```

### SOCIAL_SCOUT Contracts

```eiffel
-- Internal operations use database contracts
store_if_new (a_opp: SOCIAL_OPPORTUNITY)
    -- Only stores if URL doesn't already exist
```

## Contract Coverage

Generally light contracts due to early development stage.
