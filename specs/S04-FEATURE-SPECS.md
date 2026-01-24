# S04: FEATURE SPECIFICATIONS
**Library**: simple_social
**Status**: BACKWASH (retroactive documentation)
**Date**: 2026-01-23

## SOCIAL_DATABASE Features

### Opportunity Operations
| Feature | Signature | Description |
|---------|-----------|-------------|
| insert_opportunity | (SOCIAL_OPPORTUNITY): INTEGER | Create new |
| update_opportunity | (SOCIAL_OPPORTUNITY) | Update existing |
| opportunity_exists | (url: STRING): BOOLEAN | Check duplicate |
| opportunities_by_status | (status: INTEGER): ARRAYED_LIST | Filter by status |
| actionable_opportunities | : ARRAYED_LIST | Status 0,1,2 |
| recent_opportunities | (limit: INTEGER): ARRAYED_LIST | Most recent |

### Draft Operations
| Feature | Signature | Description |
|---------|-----------|-------------|
| insert_draft | (SOCIAL_DRAFT): INTEGER | Create draft |
| update_draft | (SOCIAL_DRAFT) | Update draft |
| drafts_for_opportunity | (id: INTEGER): ARRAYED_LIST | Get drafts |
| pending_drafts | : ARRAYED_LIST | Status 0,1 |

### Engagement Operations
| Feature | Signature | Description |
|---------|-----------|-------------|
| insert_engagement | (SOCIAL_ENGAGEMENT): INTEGER | Create |
| update_engagement | (SOCIAL_ENGAGEMENT) | Update |
| active_engagements | : ARRAYED_LIST | is_active = 1 |
| engagements_with_unread | : ARRAYED_LIST | unread > 0 |

### Resource Operations
| Feature | Signature | Description |
|---------|-----------|-------------|
| insert_resource | (...): INTEGER | Add resource |
| get_all_resources | : ARRAYED_LIST | All active |
| get_resources_by_category | (cat: STRING): ARRAYED_LIST | Filter |
| resource_categories | : ARRAYED_LIST | Distinct categories |

### Statistics
| Feature | Signature | Description |
|---------|-----------|-------------|
| opportunity_count | : INTEGER | Total count |
| actionable_count | : INTEGER | Actionable count |
| pending_draft_count | : INTEGER | Pending drafts |
| unread_reply_count | : INTEGER | Unread replies |
| resource_count | : INTEGER | Active resources |
