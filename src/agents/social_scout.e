note
	description: "[
		SOCIAL_SCOUT - SCOOP agent that searches platforms for opportunities.

		Runs searches across configured platforms and stores
		discovered opportunities in the database.
	]"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_SCOUT

create
	make

feature {NONE} -- Initialization

	make (a_settings: SOCIAL_SETTINGS; a_database: SOCIAL_DATABASE)
			-- Create scout with settings and database.
		do
			settings := a_settings
			database := a_database
			create reddit_api.make (a_settings)
			is_running := False
			create last_scan.make_now_utc
		end

feature -- Access

	settings: SOCIAL_SETTINGS
	database: SOCIAL_DATABASE
	reddit_api: REDDIT_API
	last_scan: DATE_TIME
	is_running: BOOLEAN

	opportunities_found: INTEGER
			-- Count of opportunities found in last scan.

feature -- Operations

	scan_all
			-- Scan all enabled platforms.
		do
			is_running := True
			opportunities_found := 0

			-- Scan each platform
			scan_reddit
			-- scan_stackoverflow
			-- scan_hackernews
			-- scan_github
			-- scan_devto

			create last_scan.make_now_utc
			is_running := False
		end

	scan_reddit
			-- Search Reddit for opportunities.
		local
			results: ARRAYED_LIST [SOCIAL_OPPORTUNITY]
			subreddits: ARRAY [STRING_8]
		do
			if reddit_api.is_configured then
				-- Relevant programming subreddits
				subreddits := <<
					"programming",
					"learnprogramming",
					"coding",
					"softwareengineering",
					"compsci",
					"AskProgramming",
					"rust",
					"ada",
					"podcasting",
					"podcasts",
					"VideoEditing",
					"NewTubers",
					"selfhosted"
				>>

				-- Search with each keyword
				across settings.keywords as kw loop
					results := reddit_api.search_subreddits (subreddits, kw, 10)
					across results as opp loop
						store_if_new (opp)
					end
				end
			end
		end

feature {NONE} -- Implementation

	store_if_new (a_opp: SOCIAL_OPPORTUNITY)
			-- Store opportunity if not already in database.
		do
			if not url_exists (a_opp.url) then
				do_insert_opportunity (a_opp)
				opportunities_found := opportunities_found + 1
			end
		end

	url_exists (a_url: STRING_32): BOOLEAN
			-- Check if URL already exists.
		do
			Result := database.opportunity_exists (a_url)
		end

	do_insert_opportunity (a_opp: SOCIAL_OPPORTUNITY)
			-- Insert opportunity.
		local
			id: INTEGER
		do
			id := database.insert_opportunity (a_opp)
		end

end
