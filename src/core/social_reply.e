note
	description: "[
		SOCIAL_REPLY - A reply to one of our engagements.

		Represents someone responding to our posted content,
		triggering another cycle of review and response.
	]"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_REPLY

create
	make,
	make_from_db

feature {NONE} -- Initialization

	make (a_engagement_id: INTEGER; a_url: READABLE_STRING_GENERAL;
			a_author: READABLE_STRING_GENERAL; a_content: READABLE_STRING_GENERAL)
			-- Create new reply record.
		require
			valid_engagement: a_engagement_id > 0
			url_not_empty: not a_url.is_empty
			content_not_empty: not a_content.is_empty
		do
			id := 0
			engagement_id := a_engagement_id
			reply_url := a_url.to_string_32
			author := a_author.to_string_32
			content := a_content.to_string_32
			is_read := False
			needs_response := False
			create discovered_at.make_now_utc
		ensure
			engagement_set: engagement_id = a_engagement_id
			url_set: reply_url.same_string_general (a_url)
			not_read: not is_read
		end

	make_from_db (a_id: INTEGER; a_eng_id: INTEGER; a_url: STRING_32;
			a_author: STRING_32; a_content: STRING_32; a_read: BOOLEAN;
			a_needs_response: BOOLEAN; a_discovered: DATE_TIME)
			-- Reconstruct from database row.
		require
			positive_id: a_id > 0
		do
			id := a_id
			engagement_id := a_eng_id
			reply_url := a_url
			author := a_author
			content := a_content
			is_read := a_read
			needs_response := a_needs_response
			discovered_at := a_discovered
		ensure
			id_set: id = a_id
		end

feature -- Access

	id: INTEGER
			-- Database ID (0 if not persisted).

	engagement_id: INTEGER
			-- ID of the engagement this is a reply to.

	reply_url: STRING_32
			-- Direct URL to this reply.

	author: STRING_32
			-- Username of the person who replied.

	content: STRING_32
			-- The reply content.

	is_read: BOOLEAN
			-- Has this been reviewed?

	needs_response: BOOLEAN
			-- Have we flagged this for response?

	discovered_at: DATE_TIME
			-- When we found this reply.

feature -- Status Queries

	is_actionable: BOOLEAN
			-- Does this need attention?
		do
			Result := not is_read or needs_response
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

	mark_read
			-- Mark as read.
		do
			is_read := True
		ensure
			is_read: is_read
		end

	flag_for_response
			-- Mark as needing a response.
		do
			needs_response := True
			is_read := True
		ensure
			needs_response: needs_response
			is_read: is_read
		end

	clear_response_flag
			-- Clear the needs_response flag (after responding).
		do
			needs_response := False
		ensure
			no_response_needed: not needs_response
		end

feature -- Display

	preview (a_length: INTEGER): STRING_32
			-- First a_length characters of content.
		require
			positive_length: a_length > 0
		do
			if content.count <= a_length then
				Result := content.twin
			else
				Result := content.substring (1, a_length)
				Result.append_string_general ("...")
			end
		ensure
			result_attached: Result /= Void
		end

	summary: STRING_32
			-- One-line summary.
		do
			create Result.make (100)
			Result.append_string_general ("@")
			Result.append (author)
			Result.append_string_general (": ")
			Result.append (preview (60))
			if needs_response then
				Result.append_string_general (" [RESPOND]")
			elseif not is_read then
				Result.append_string_general (" [NEW]")
			end
		end

invariant
	reply_url_not_empty: not reply_url.is_empty
	content_not_empty: not content.is_empty
	valid_engagement: engagement_id > 0

end
