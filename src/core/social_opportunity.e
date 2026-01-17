note
	description: "[
		SOCIAL_OPPORTUNITY - A discovered thread/discussion where engagement may be relevant.

		Represents a potential place to contribute to the conversation about
		Eiffel, Design by Contract, simple_speech, or related topics.
	]"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_OPPORTUNITY

create
	make,
	make_from_db

feature {NONE} -- Initialization

	make (a_platform: INTEGER; a_url: READABLE_STRING_GENERAL; a_title: READABLE_STRING_GENERAL)
			-- Create new opportunity.
		require
			valid_platform: (create {SOCIAL_PLATFORM}).is_valid (a_platform)
			url_not_empty: not a_url.is_empty
			title_not_empty: not a_title.is_empty
		do
			id := 0
			platform := a_platform
			url := a_url.to_string_32
			title := a_title.to_string_32
			create snippet.make_empty
			relevance_score := 0.0
			status := Status_new
			create discovered_at.make_now_utc
			create {DATE_TIME} last_checked.make_now_utc
		ensure
			platform_set: platform = a_platform
			url_set: url.same_string_general (a_url)
			title_set: title.same_string_general (a_title)
			is_new: status = Status_new
		end

	make_from_db (a_id: INTEGER; a_platform: INTEGER; a_url: STRING_32; a_title: STRING_32;
			a_snippet: STRING_32; a_score: REAL_64; a_status: INTEGER;
			a_discovered: DATE_TIME; a_checked: DATE_TIME)
			-- Reconstruct from database row.
		require
			positive_id: a_id > 0
		do
			id := a_id
			platform := a_platform
			url := a_url
			title := a_title
			snippet := a_snippet
			relevance_score := a_score
			status := a_status
			discovered_at := a_discovered
			last_checked := a_checked
		ensure
			id_set: id = a_id
		end

feature -- Access

	id: INTEGER
			-- Database ID (0 if not persisted).

	platform: INTEGER
			-- Platform identifier (see SOCIAL_PLATFORM).

	url: STRING_32
			-- Direct URL to the thread/post.

	title: STRING_32
			-- Thread/post title.

	snippet: STRING_32
			-- Relevant excerpt from content.

	relevance_score: REAL_64
			-- AI-assigned relevance (0.0 to 1.0).

	status: INTEGER
			-- Current status (see Status_* constants).

	discovered_at: DATE_TIME
			-- When this opportunity was found.

	last_checked: DATE_TIME
			-- When this was last examined.

feature -- Status Constants

	Status_new: INTEGER = 0
			-- Just discovered, not yet reviewed.

	Status_reviewing: INTEGER = 1
			-- Human is reviewing.

	Status_drafting: INTEGER = 2
			-- Draft response in progress.

	Status_skipped: INTEGER = 3
			-- Decided not to engage.

	Status_posted: INTEGER = 4
			-- Response posted, now monitoring.

	Status_closed: INTEGER = 5
			-- Thread is old/locked, no longer relevant.

feature -- Status Queries

	is_new: BOOLEAN
			-- Is this a new opportunity?
		do
			Result := status = Status_new
		end

	is_actionable: BOOLEAN
			-- Can we still act on this?
		do
			Result := status = Status_new or status = Status_reviewing or status = Status_drafting
		end

	is_monitoring: BOOLEAN
			-- Are we monitoring for replies?
		do
			Result := status = Status_posted
		end

	status_name: STRING_8
			-- Human-readable status.
		do
			inspect status
			when Status_new then Result := "New"
			when Status_reviewing then Result := "Reviewing"
			when Status_drafting then Result := "Drafting"
			when Status_skipped then Result := "Skipped"
			when Status_posted then Result := "Posted"
			when Status_closed then Result := "Closed"
			else
				Result := "Unknown"
			end
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

	set_snippet (a_snippet: READABLE_STRING_GENERAL)
			-- Set content snippet.
		do
			snippet := a_snippet.to_string_32
		ensure
			snippet_set: snippet.same_string_general (a_snippet)
		end

	set_relevance (a_score: REAL_64)
			-- Set AI relevance score.
		require
			valid_score: a_score >= 0.0 and a_score <= 1.0
		do
			relevance_score := a_score
		ensure
			score_set: relevance_score = a_score
		end

	set_status (a_status: INTEGER)
			-- Update status.
		require
			valid_status: a_status >= Status_new and a_status <= Status_closed
		do
			status := a_status
		ensure
			status_set: status = a_status
		end

	mark_checked
			-- Update last_checked timestamp.
		do
			create last_checked.make_now_utc
		end

feature -- Display

	platform_icon: STRING_8
			-- Short platform identifier.
		do
			Result := (create {SOCIAL_PLATFORM}).icon (platform)
		end

	platform_name: STRING_8
			-- Full platform name.
		do
			Result := (create {SOCIAL_PLATFORM}).name (platform)
		end

	summary: STRING_32
			-- One-line summary for display.
		do
			create Result.make (100)
			Result.append_string_general (platform_icon)
			Result.append_character (' ')
			Result.append (title)
			if relevance_score > 0.0 then
				Result.append_string_general (" [")
				Result.append_string_general ((relevance_score * 100).truncated_to_integer.out)
				Result.append_string_general ("%%]")
			end
		end

invariant
	url_not_empty: not url.is_empty
	title_not_empty: not title.is_empty
	valid_score: relevance_score >= 0.0 and relevance_score <= 1.0
	valid_status: status >= Status_new and status <= Status_closed

end
