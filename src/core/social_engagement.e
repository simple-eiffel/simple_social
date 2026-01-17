note
	description: "[
		SOCIAL_ENGAGEMENT - A posted response that is being monitored.

		Tracks where we have posted, so we can watch for replies
		and continue the conversation.
	]"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_ENGAGEMENT

create
	make,
	make_from_db

feature {NONE} -- Initialization

	make (a_opportunity_id: INTEGER; a_draft_id: INTEGER; a_post_url: READABLE_STRING_GENERAL)
			-- Create new engagement record.
		require
			valid_opportunity: a_opportunity_id > 0
			valid_draft: a_draft_id > 0
			url_not_empty: not a_post_url.is_empty
		do
			id := 0
			opportunity_id := a_opportunity_id
			draft_id := a_draft_id
			post_url := a_post_url.to_string_32
			reply_count := 0
			unread_replies := 0
			create posted_at.make_now_utc
			create {DATE_TIME} last_checked.make_now_utc
			is_active := True
		ensure
			opportunity_set: opportunity_id = a_opportunity_id
			draft_set: draft_id = a_draft_id
			url_set: post_url.same_string_general (a_post_url)
			is_active: is_active
		end

	make_from_db (a_id: INTEGER; a_opp_id: INTEGER; a_draft_id: INTEGER;
			a_url: STRING_32; a_reply_count: INTEGER; a_unread: INTEGER;
			a_posted: DATE_TIME; a_checked: DATE_TIME; a_active: BOOLEAN)
			-- Reconstruct from database row.
		require
			positive_id: a_id > 0
		do
			id := a_id
			opportunity_id := a_opp_id
			draft_id := a_draft_id
			post_url := a_url
			reply_count := a_reply_count
			unread_replies := a_unread
			posted_at := a_posted
			last_checked := a_checked
			is_active := a_active
		ensure
			id_set: id = a_id
		end

feature -- Access

	id: INTEGER
			-- Database ID (0 if not persisted).

	opportunity_id: INTEGER
			-- ID of the original opportunity.

	draft_id: INTEGER
			-- ID of the draft that was posted.

	post_url: STRING_32
			-- URL of our posted response.

	reply_count: INTEGER
			-- Total replies received.

	unread_replies: INTEGER
			-- Replies not yet reviewed.

	posted_at: DATE_TIME
			-- When we posted.

	last_checked: DATE_TIME
			-- When we last checked for replies.

	is_active: BOOLEAN
			-- Are we still monitoring this?

feature -- Status Queries

	has_unread: BOOLEAN
			-- Are there unread replies?
		do
			Result := unread_replies > 0
		end

	needs_attention: BOOLEAN
			-- Should this be highlighted?
		do
			Result := is_active and has_unread
		end

feature -- Modification

	set_id (a_id: INTEGER)
			-- Set database ID after insert.
		require
			not_yet_set: id = 0
			positive: a_id > 0
		do
			id := a_id
		ensure
			id_set: id = a_id
		end

	record_replies (a_new_count: INTEGER)
			-- Update reply count after checking.
		require
			non_negative: a_new_count >= 0
		local
			new_replies: INTEGER
		do
			new_replies := a_new_count - reply_count
			if new_replies > 0 then
				unread_replies := unread_replies + new_replies
			end
			reply_count := a_new_count
			create last_checked.make_now_utc
		ensure
			count_updated: reply_count = a_new_count
		end

	mark_replies_read
			-- Mark all replies as read.
		do
			unread_replies := 0
		ensure
			no_unread: unread_replies = 0
		end

	mark_read (a_count: INTEGER)
			-- Mark specific number of replies as read.
		require
			valid_count: a_count > 0 and a_count <= unread_replies
		do
			unread_replies := unread_replies - a_count
		ensure
			reduced: unread_replies = old unread_replies - a_count
		end

	deactivate
			-- Stop monitoring this engagement.
		do
			is_active := False
		ensure
			not_active: not is_active
		end

	reactivate
			-- Resume monitoring.
		do
			is_active := True
		ensure
			is_active: is_active
		end

feature -- Display

	summary: STRING_32
			-- One-line summary for display.
		do
			create Result.make (100)
			Result.append_string_general ("Posted ")
			Result.append_string_general (posted_at.out)
			if has_unread then
				Result.append_string_general (" [")
				Result.append_string_general (unread_replies.out)
				Result.append_string_general (" new replies]")
			elseif reply_count > 0 then
				Result.append_string_general (" (")
				Result.append_string_general (reply_count.out)
				Result.append_string_general (" replies)")
			end
		end

invariant
	post_url_not_empty: not post_url.is_empty
	valid_opportunity: opportunity_id > 0
	valid_draft: draft_id > 0
	non_negative_counts: reply_count >= 0 and unread_replies >= 0
	unread_within_total: unread_replies <= reply_count

end
