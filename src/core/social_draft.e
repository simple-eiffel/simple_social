note
	description: "[
		SOCIAL_DRAFT - An AI-generated response awaiting human review.

		Contains the suggested response text, linked to an opportunity,
		with support for human editing and regeneration.
	]"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_DRAFT

create
	make,
	make_from_db

feature {NONE} -- Initialization

	make (a_opportunity_id: INTEGER; a_content: READABLE_STRING_GENERAL)
			-- Create new draft for an opportunity.
		require
			valid_opportunity: a_opportunity_id > 0
			content_not_empty: not a_content.is_empty
		do
			id := 0
			opportunity_id := a_opportunity_id
			content := a_content.to_string_32
			create original_content.make_from_string (content)
			status := Status_pending
			create created_at.make_now_utc
			create {DATE_TIME} modified_at.make_now_utc
			generation_count := 1
		ensure
			opportunity_set: opportunity_id = a_opportunity_id
			content_set: content.same_string_general (a_content)
			is_pending: status = Status_pending
		end

	make_from_db (a_id: INTEGER; a_opp_id: INTEGER; a_content: STRING_32;
			a_original: STRING_32; a_status: INTEGER; a_created: DATE_TIME;
			a_modified: DATE_TIME; a_gen_count: INTEGER)
			-- Reconstruct from database row.
		require
			positive_id: a_id > 0
		do
			id := a_id
			opportunity_id := a_opp_id
			content := a_content
			original_content := a_original
			status := a_status
			created_at := a_created
			modified_at := a_modified
			generation_count := a_gen_count
		ensure
			id_set: id = a_id
		end

feature -- Access

	id: INTEGER
			-- Database ID (0 if not persisted).

	opportunity_id: INTEGER
			-- ID of the opportunity this draft responds to.

	content: STRING_32
			-- Current draft content (may be edited).

	original_content: STRING_32
			-- Original AI-generated content.

	status: INTEGER
			-- Current status.

	created_at: DATE_TIME
			-- When draft was created.

	modified_at: DATE_TIME
			-- When draft was last modified.

	generation_count: INTEGER
			-- How many times AI has generated for this opportunity.

feature -- Status Constants

	Status_pending: INTEGER = 0
			-- Awaiting human review.

	Status_editing: INTEGER = 1
			-- Human is actively editing.

	Status_approved: INTEGER = 2
			-- Approved, ready to post.

	Status_posted: INTEGER = 3
			-- Has been posted.

	Status_rejected: INTEGER = 4
			-- Rejected, won't be used.

feature -- Status Queries

	is_pending: BOOLEAN
			-- Awaiting review?
		do
			Result := status = Status_pending
		end

	is_editable: BOOLEAN
			-- Can this draft be edited?
		do
			Result := status = Status_pending or status = Status_editing
		end

	is_ready_to_post: BOOLEAN
			-- Has this been approved?
		do
			Result := status = Status_approved
		end

	was_modified: BOOLEAN
			-- Has the content been changed from original?
		do
			Result := not content.same_string (original_content)
		end

	status_name: STRING_8
			-- Human-readable status.
		do
			inspect status
			when Status_pending then Result := "Pending Review"
			when Status_editing then Result := "Editing"
			when Status_approved then Result := "Approved"
			when Status_posted then Result := "Posted"
			when Status_rejected then Result := "Rejected"
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

	update_content (a_content: READABLE_STRING_GENERAL)
			-- Update draft content (human edit).
		require
			is_editable: is_editable
			not_empty: not a_content.is_empty
		do
			content := a_content.to_string_32
			create modified_at.make_now_utc
			if status = Status_pending then
				status := Status_editing
			end
		ensure
			content_updated: content.same_string_general (a_content)
		end

	regenerate (a_new_content: READABLE_STRING_GENERAL)
			-- Replace with new AI generation.
		require
			is_editable: is_editable
			not_empty: not a_new_content.is_empty
		do
			content := a_new_content.to_string_32
			original_content := a_new_content.to_string_32
			generation_count := generation_count + 1
			status := Status_pending
			create modified_at.make_now_utc
		ensure
			content_updated: content.same_string_general (a_new_content)
			count_incremented: generation_count = old generation_count + 1
		end

	approve
			-- Mark as approved for posting.
		require
			is_editable: is_editable
		do
			status := Status_approved
			create modified_at.make_now_utc
		ensure
			is_approved: status = Status_approved
		end

	reject
			-- Mark as rejected.
		require
			not_posted: status /= Status_posted
		do
			status := Status_rejected
			create modified_at.make_now_utc
		ensure
			is_rejected: status = Status_rejected
		end

	mark_posted
			-- Mark as posted.
		require
			was_approved: status = Status_approved
		do
			status := Status_posted
			create modified_at.make_now_utc
		ensure
			is_posted: status = Status_posted
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

invariant
	content_not_empty: not content.is_empty
	original_not_empty: not original_content.is_empty
	positive_opportunity: opportunity_id > 0
	positive_generation: generation_count >= 1

end
