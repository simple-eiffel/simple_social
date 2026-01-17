note
	description: "[
		SOCIAL_DATABASE - SQLite persistence for social monitoring data.

		Handles all CRUD operations for opportunities, drafts,
		engagements, and replies.
	]"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_DATABASE

inherit
	SIMPLE_SQL_DATABASE
		rename
			make as make_database
		end

create
	make

feature {NONE} -- Initialization

	make (a_path: READABLE_STRING_GENERAL)
			-- Open or create database at path.
		require
			path_not_empty: not a_path.is_empty
		do
			make_database (a_path)
			if is_open then
				ensure_schema
			end
		end

feature -- Schema

	ensure_schema
			-- Create tables if they don't exist.
		do
			execute (Schema_opportunities)
			execute (Schema_drafts)
			execute (Schema_engagements)
			execute (Schema_replies)
			execute (Schema_keywords)
			execute (Schema_resources)
			execute (Schema_resource_tags)
			execute (Index_opp_status)
			execute (Index_opp_platform)
			execute (Index_draft_status)
			execute (Index_engagement_active)
			execute (Index_reply_unread)
			execute (Index_resource_category)
			execute (Index_resource_tag)
		end

feature -- Opportunity Operations

	insert_opportunity (a_opp: SOCIAL_OPPORTUNITY): INTEGER
			-- Insert opportunity, return new ID.
		require
			not_persisted: a_opp.id = 0
		local
			sql: STRING_8
		do
			sql := "INSERT INTO opportunities (platform, url, title, snippet, relevance_score, status, discovered_at, last_checked) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
			execute_with_args (sql, <<a_opp.platform, a_opp.url.to_string_8, a_opp.title.to_string_8, a_opp.snippet.to_string_8, a_opp.relevance_score, a_opp.status, a_opp.discovered_at.out, a_opp.last_checked.out>>)
			Result := last_insert_rowid.to_integer_32
			if Result > 0 then
				a_opp.set_id (Result)
			end
		ensure
			has_id: Result > 0 implies a_opp.id = Result
		end

	update_opportunity (a_opp: SOCIAL_OPPORTUNITY)
			-- Update existing opportunity.
		require
			is_persisted: a_opp.id > 0
		local
			sql: STRING_8
		do
			sql := "UPDATE opportunities SET status = ?, relevance_score = ?, snippet = ?, last_checked = ? WHERE id = ?"
			execute_with_args (sql, <<a_opp.status, a_opp.relevance_score, a_opp.snippet.to_string_8, a_opp.last_checked.out, a_opp.id>>)
		end

	opportunity_exists (a_url: READABLE_STRING_GENERAL): BOOLEAN
			-- Does an opportunity with this URL already exist?
		local
			res: SIMPLE_SQL_RESULT
		do
			res := query_with_args ("SELECT COUNT(*) as cnt FROM opportunities WHERE url = ?", <<a_url.to_string_8>>)
			if not res.rows.is_empty and then attached res.rows.first as row then
				Result := row.integer_value ("cnt") > 0
			end
		end

	opportunities_by_status (a_status: INTEGER): ARRAYED_LIST [SOCIAL_OPPORTUNITY]
			-- Get all opportunities with given status.
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (20)
			res := query_with_args ("SELECT id, platform, url, title, snippet, relevance_score, status, discovered_at, last_checked FROM opportunities WHERE status = ? ORDER BY relevance_score DESC, discovered_at DESC", <<a_status>>)
			across res.rows as row loop
				Result.extend (row_to_opportunity (row))
			end
		end

	actionable_opportunities: ARRAYED_LIST [SOCIAL_OPPORTUNITY]
			-- Get all opportunities that can be acted upon.
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (20)
			res := query ("SELECT id, platform, url, title, snippet, relevance_score, status, discovered_at, last_checked FROM opportunities WHERE status IN (0, 1, 2) ORDER BY relevance_score DESC, discovered_at DESC")
			across res.rows as row loop
				Result.extend (row_to_opportunity (row))
			end
		end

	recent_opportunities (a_limit: INTEGER): ARRAYED_LIST [SOCIAL_OPPORTUNITY]
			-- Get most recent opportunities.
		require
			positive_limit: a_limit > 0
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (a_limit)
			res := query_with_args ("SELECT id, platform, url, title, snippet, relevance_score, status, discovered_at, last_checked FROM opportunities ORDER BY discovered_at DESC LIMIT ?", <<a_limit>>)
			across res.rows as row loop
				Result.extend (row_to_opportunity (row))
			end
		end

feature -- Draft Operations

	insert_draft (a_draft: SOCIAL_DRAFT): INTEGER
			-- Insert draft, return new ID.
		require
			not_persisted: a_draft.id = 0
		local
			sql: STRING_8
		do
			sql := "INSERT INTO drafts (opportunity_id, content, original_content, status, created_at, modified_at, generation_count) VALUES (?, ?, ?, ?, ?, ?, ?)"
			execute_with_args (sql, <<a_draft.opportunity_id, a_draft.content.to_string_8, a_draft.original_content.to_string_8, a_draft.status, a_draft.created_at.out, a_draft.modified_at.out, a_draft.generation_count>>)
			Result := last_insert_rowid.to_integer_32
			if Result > 0 then
				a_draft.set_id (Result)
			end
		end

	update_draft (a_draft: SOCIAL_DRAFT)
			-- Update existing draft.
		require
			is_persisted: a_draft.id > 0
		local
			sql: STRING_8
		do
			sql := "UPDATE drafts SET content = ?, status = ?, modified_at = ?, generation_count = ? WHERE id = ?"
			execute_with_args (sql, <<a_draft.content.to_string_8, a_draft.status, a_draft.modified_at.out, a_draft.generation_count, a_draft.id>>)
		end

	drafts_for_opportunity (a_opp_id: INTEGER): ARRAYED_LIST [SOCIAL_DRAFT]
			-- Get all drafts for an opportunity.
		require
			valid_id: a_opp_id > 0
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (3)
			res := query_with_args ("SELECT id, opportunity_id, content, original_content, status, created_at, modified_at, generation_count FROM drafts WHERE opportunity_id = ? ORDER BY created_at DESC", <<a_opp_id>>)
			across res.rows as row loop
				Result.extend (row_to_draft (row))
			end
		end

	pending_drafts: ARRAYED_LIST [SOCIAL_DRAFT]
			-- Get all drafts pending review.
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (20)
			res := query ("SELECT id, opportunity_id, content, original_content, status, created_at, modified_at, generation_count FROM drafts WHERE status IN (0, 1) ORDER BY modified_at DESC")
			across res.rows as row loop
				Result.extend (row_to_draft (row))
			end
		end

feature -- Engagement Operations

	insert_engagement (a_eng: SOCIAL_ENGAGEMENT): INTEGER
			-- Insert engagement, return new ID.
		require
			not_persisted: a_eng.id = 0
		local
			sql: STRING_8
		do
			sql := "INSERT INTO engagements (opportunity_id, draft_id, post_url, reply_count, unread_replies, posted_at, last_checked, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
			execute_with_args (sql, <<a_eng.opportunity_id, a_eng.draft_id, a_eng.post_url.to_string_8, a_eng.reply_count, a_eng.unread_replies, a_eng.posted_at.out, a_eng.last_checked.out, if a_eng.is_active then 1 else 0 end>>)
			Result := last_insert_rowid.to_integer_32
			if Result > 0 then
				a_eng.set_id (Result)
			end
		end

	update_engagement (a_eng: SOCIAL_ENGAGEMENT)
			-- Update existing engagement.
		require
			is_persisted: a_eng.id > 0
		local
			sql: STRING_8
		do
			sql := "UPDATE engagements SET reply_count = ?, unread_replies = ?, last_checked = ?, is_active = ? WHERE id = ?"
			execute_with_args (sql, <<a_eng.reply_count, a_eng.unread_replies, a_eng.last_checked.out, if a_eng.is_active then 1 else 0 end, a_eng.id>>)
		end

	active_engagements: ARRAYED_LIST [SOCIAL_ENGAGEMENT]
			-- Get all active engagements.
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (20)
			res := query ("SELECT id, opportunity_id, draft_id, post_url, reply_count, unread_replies, posted_at, last_checked, is_active FROM engagements WHERE is_active = 1 ORDER BY unread_replies DESC, last_checked ASC")
			across res.rows as row loop
				Result.extend (row_to_engagement (row))
			end
		end

	engagements_with_unread: ARRAYED_LIST [SOCIAL_ENGAGEMENT]
			-- Get engagements that have unread replies.
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (10)
			res := query ("SELECT id, opportunity_id, draft_id, post_url, reply_count, unread_replies, posted_at, last_checked, is_active FROM engagements WHERE unread_replies > 0 ORDER BY unread_replies DESC")
			across res.rows as row loop
				Result.extend (row_to_engagement (row))
			end
		end

feature -- Reply Operations

	insert_reply (a_reply: SOCIAL_REPLY): INTEGER
			-- Insert reply, return new ID.
		require
			not_persisted: a_reply.id = 0
		local
			sql: STRING_8
		do
			sql := "INSERT INTO replies (engagement_id, reply_url, author, content, is_read, needs_response, discovered_at) VALUES (?, ?, ?, ?, ?, ?, ?)"
			execute_with_args (sql, <<a_reply.engagement_id, a_reply.reply_url.to_string_8, a_reply.author.to_string_8, a_reply.content.to_string_8, if a_reply.is_read then 1 else 0 end, if a_reply.needs_response then 1 else 0 end, a_reply.discovered_at.out>>)
			Result := last_insert_rowid.to_integer_32
			if Result > 0 then
				a_reply.set_id (Result)
			end
		end

	update_reply (a_reply: SOCIAL_REPLY)
			-- Update existing reply.
		require
			is_persisted: a_reply.id > 0
		local
			sql: STRING_8
		do
			sql := "UPDATE replies SET is_read = ?, needs_response = ? WHERE id = ?"
			execute_with_args (sql, <<if a_reply.is_read then 1 else 0 end, if a_reply.needs_response then 1 else 0 end, a_reply.id>>)
		end

	replies_for_engagement (a_eng_id: INTEGER): ARRAYED_LIST [SOCIAL_REPLY]
			-- Get all replies for an engagement.
		require
			valid_id: a_eng_id > 0
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (10)
			res := query_with_args ("SELECT id, engagement_id, reply_url, author, content, is_read, needs_response, discovered_at FROM replies WHERE engagement_id = ? ORDER BY discovered_at DESC", <<a_eng_id>>)
			across res.rows as row loop
				Result.extend (row_to_reply (row))
			end
		end

	unread_replies: ARRAYED_LIST [SOCIAL_REPLY]
			-- Get all unread replies.
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (20)
			res := query ("SELECT id, engagement_id, reply_url, author, content, is_read, needs_response, discovered_at FROM replies WHERE is_read = 0 ORDER BY discovered_at DESC")
			across res.rows as row loop
				Result.extend (row_to_reply (row))
			end
		end

feature -- Statistics

	opportunity_count: INTEGER
			-- Total opportunities.
		local
			res: SIMPLE_SQL_RESULT
		do
			res := query ("SELECT COUNT(*) as cnt FROM opportunities")
			if not res.rows.is_empty and then attached res.rows.first as row then
				Result := row.integer_value ("cnt")
			end
		end

	actionable_count: INTEGER
			-- Opportunities that can be acted upon.
		local
			res: SIMPLE_SQL_RESULT
		do
			res := query ("SELECT COUNT(*) as cnt FROM opportunities WHERE status IN (0, 1, 2)")
			if not res.rows.is_empty and then attached res.rows.first as row then
				Result := row.integer_value ("cnt")
			end
		end

	pending_draft_count: INTEGER
			-- Drafts awaiting review.
		local
			res: SIMPLE_SQL_RESULT
		do
			res := query ("SELECT COUNT(*) as cnt FROM drafts WHERE status IN (0, 1)")
			if not res.rows.is_empty and then attached res.rows.first as row then
				Result := row.integer_value ("cnt")
			end
		end

	unread_reply_count: INTEGER
			-- Unread replies.
		local
			res: SIMPLE_SQL_RESULT
		do
			res := query ("SELECT COUNT(*) as cnt FROM replies WHERE is_read = 0")
			if not res.rows.is_empty and then attached res.rows.first as row then
				Result := row.integer_value ("cnt")
			end
		end

feature -- Resource Operations

	insert_resource (a_url, a_title, a_description, a_category, a_keywords, a_source: STRING_8; a_quality: REAL_64): INTEGER
			-- Insert resource and return ID.
		local
			sql: STRING_8
			dt: DATE_TIME
		do
			create dt.make_now_utc
			sql := "INSERT OR IGNORE INTO resources (url, title, description, category, keywords, source, quality_score, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
			execute_with_args (sql, <<a_url, a_title, a_description, a_category, a_keywords, a_source, a_quality, dt.out>>)
			Result := last_insert_rowid.to_integer_32
		end

	get_all_resources: ARRAYED_LIST [TUPLE [id: INTEGER; url: STRING_32; title: STRING_32; description: STRING_32; category: STRING_32; quality: REAL_64]]
			-- Get all active resources.
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (50)
			res := query ("SELECT id, url, title, description, category, quality_score FROM resources WHERE is_active = 1 ORDER BY category, quality_score DESC")
			across res.rows as row loop
				Result.extend ([
					row.integer_value ("id"),
					row.string_value ("url"),
					row.string_value ("title"),
					row.string_value ("description"),
					row.string_value ("category"),
					row.real_value ("quality_score")
				])
			end
		end

	get_resources_by_category (a_category: STRING_8): ARRAYED_LIST [TUPLE [id: INTEGER; url: STRING_32; title: STRING_32; description: STRING_32; quality: REAL_64]]
			-- Get resources in category.
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (20)
			res := query_with_args ("SELECT id, url, title, description, quality_score FROM resources WHERE is_active = 1 AND category = ? ORDER BY quality_score DESC", <<a_category>>)
			across res.rows as row loop
				Result.extend ([
					row.integer_value ("id"),
					row.string_value ("url"),
					row.string_value ("title"),
					row.string_value ("description"),
					row.real_value ("quality_score")
				])
			end
		end

	resource_count: INTEGER
			-- Count of active resources.
		local
			res: SIMPLE_SQL_RESULT
		do
			res := query ("SELECT COUNT(*) as cnt FROM resources WHERE is_active = 1")
			if not res.rows.is_empty and then attached res.rows.first as row then
				Result := row.integer_value ("cnt")
			end
		end

	resource_categories: ARRAYED_LIST [STRING_32]
			-- Get distinct categories.
		local
			res: SIMPLE_SQL_RESULT
		do
			create Result.make (10)
			res := query ("SELECT DISTINCT category FROM resources WHERE is_active = 1 ORDER BY category")
			across res.rows as row loop
				Result.extend (row.string_value ("category"))
			end
		end

feature {NONE} -- Row Mappers

	row_to_opportunity (a_row: SIMPLE_SQL_ROW): SOCIAL_OPPORTUNITY
			-- Map row to opportunity.
		local
			dt1, dt2: DATE_TIME
		do
			create dt1.make_from_string_default (a_row.string_value ("discovered_at").to_string_8)
			create dt2.make_from_string_default (a_row.string_value ("last_checked").to_string_8)
			create Result.make_from_db (
				a_row.integer_value ("id"),
				a_row.integer_value ("platform"),
				a_row.string_value ("url"),
				a_row.string_value ("title"),
				a_row.string_value ("snippet"),
				a_row.real_value ("relevance_score"),
				a_row.integer_value ("status"),
				dt1,
				dt2
			)
		end

	row_to_draft (a_row: SIMPLE_SQL_ROW): SOCIAL_DRAFT
			-- Map row to draft.
		local
			dt1, dt2: DATE_TIME
		do
			create dt1.make_from_string_default (a_row.string_value ("created_at").to_string_8)
			create dt2.make_from_string_default (a_row.string_value ("modified_at").to_string_8)
			create Result.make_from_db (
				a_row.integer_value ("id"),
				a_row.integer_value ("opportunity_id"),
				a_row.string_value ("content"),
				a_row.string_value ("original_content"),
				a_row.integer_value ("status"),
				dt1,
				dt2,
				a_row.integer_value ("generation_count")
			)
		end

	row_to_engagement (a_row: SIMPLE_SQL_ROW): SOCIAL_ENGAGEMENT
			-- Map row to engagement.
		local
			dt1, dt2: DATE_TIME
		do
			create dt1.make_from_string_default (a_row.string_value ("posted_at").to_string_8)
			create dt2.make_from_string_default (a_row.string_value ("last_checked").to_string_8)
			create Result.make_from_db (
				a_row.integer_value ("id"),
				a_row.integer_value ("opportunity_id"),
				a_row.integer_value ("draft_id"),
				a_row.string_value ("post_url"),
				a_row.integer_value ("reply_count"),
				a_row.integer_value ("unread_replies"),
				dt1,
				dt2,
				a_row.integer_value ("is_active") = 1
			)
		end

	row_to_reply (a_row: SIMPLE_SQL_ROW): SOCIAL_REPLY
			-- Map row to reply.
		local
			dt: DATE_TIME
		do
			create dt.make_from_string_default (a_row.string_value ("discovered_at").to_string_8)
			create Result.make_from_db (
				a_row.integer_value ("id"),
				a_row.integer_value ("engagement_id"),
				a_row.string_value ("reply_url"),
				a_row.string_value ("author"),
				a_row.string_value ("content"),
				a_row.integer_value ("is_read") = 1,
				a_row.integer_value ("needs_response") = 1,
				dt
			)
		end

feature {NONE} -- Schema SQL

	Schema_opportunities: STRING_8 = "[
		CREATE TABLE IF NOT EXISTS opportunities (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			platform INTEGER NOT NULL,
			url TEXT NOT NULL UNIQUE,
			title TEXT NOT NULL,
			snippet TEXT DEFAULT '',
			relevance_score REAL DEFAULT 0.0,
			status INTEGER DEFAULT 0,
			discovered_at TEXT NOT NULL,
			last_checked TEXT NOT NULL
		)
	]"

	Schema_drafts: STRING_8 = "[
		CREATE TABLE IF NOT EXISTS drafts (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			opportunity_id INTEGER NOT NULL,
			content TEXT NOT NULL,
			original_content TEXT NOT NULL,
			status INTEGER DEFAULT 0,
			created_at TEXT NOT NULL,
			modified_at TEXT NOT NULL,
			generation_count INTEGER DEFAULT 1,
			FOREIGN KEY (opportunity_id) REFERENCES opportunities(id)
		)
	]"

	Schema_engagements: STRING_8 = "[
		CREATE TABLE IF NOT EXISTS engagements (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			opportunity_id INTEGER NOT NULL,
			draft_id INTEGER NOT NULL,
			post_url TEXT NOT NULL,
			reply_count INTEGER DEFAULT 0,
			unread_replies INTEGER DEFAULT 0,
			posted_at TEXT NOT NULL,
			last_checked TEXT NOT NULL,
			is_active INTEGER DEFAULT 1,
			FOREIGN KEY (opportunity_id) REFERENCES opportunities(id),
			FOREIGN KEY (draft_id) REFERENCES drafts(id)
		)
	]"

	Schema_replies: STRING_8 = "[
		CREATE TABLE IF NOT EXISTS replies (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			engagement_id INTEGER NOT NULL,
			reply_url TEXT NOT NULL,
			author TEXT NOT NULL,
			content TEXT NOT NULL,
			is_read INTEGER DEFAULT 0,
			needs_response INTEGER DEFAULT 0,
			discovered_at TEXT NOT NULL,
			FOREIGN KEY (engagement_id) REFERENCES engagements(id)
		)
	]"

	Schema_keywords: STRING_8 = "[
		CREATE TABLE IF NOT EXISTS keywords (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			keyword TEXT NOT NULL UNIQUE,
			category TEXT DEFAULT 'general',
			is_active INTEGER DEFAULT 1
		)
	]"

	Schema_resources: STRING_8 = "[
		CREATE TABLE IF NOT EXISTS resources (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			url TEXT NOT NULL UNIQUE,
			title TEXT NOT NULL,
			description TEXT DEFAULT '',
			category TEXT NOT NULL,
			keywords TEXT DEFAULT '',
			source TEXT DEFAULT '',
			quality_score REAL DEFAULT 0.5,
			is_active INTEGER DEFAULT 1,
			created_at TEXT NOT NULL,
			last_verified TEXT
		)
	]"

	Schema_resource_tags: STRING_8 = "[
		CREATE TABLE IF NOT EXISTS resource_tags (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			resource_id INTEGER NOT NULL,
			tag TEXT NOT NULL,
			FOREIGN KEY (resource_id) REFERENCES resources(id),
			UNIQUE(resource_id, tag)
		)
	]"

	Index_opp_status: STRING_8 = "CREATE INDEX IF NOT EXISTS idx_opp_status ON opportunities(status)"
	Index_opp_platform: STRING_8 = "CREATE INDEX IF NOT EXISTS idx_opp_platform ON opportunities(platform)"
	Index_draft_status: STRING_8 = "CREATE INDEX IF NOT EXISTS idx_draft_status ON drafts(status)"
	Index_engagement_active: STRING_8 = "CREATE INDEX IF NOT EXISTS idx_eng_active ON engagements(is_active)"
	Index_reply_unread: STRING_8 = "CREATE INDEX IF NOT EXISTS idx_reply_unread ON replies(is_read)"

	Index_resource_category: STRING_8 = "CREATE INDEX IF NOT EXISTS idx_resource_cat ON resources(category)"
	Index_resource_tag: STRING_8 = "CREATE INDEX IF NOT EXISTS idx_resource_tag ON resource_tags(tag)"

end
