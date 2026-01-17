note
	description: "[
		REDDIT_API - Reddit API client for searching and monitoring.

		Handles OAuth2 authentication and search operations.
		Read-only operations for finding relevant discussions.
	]"
	author: "Larry Rix"
	date: "$Date$"

class
	REDDIT_API

create
	make

feature {NONE} -- Initialization

	make (a_settings: SOCIAL_SETTINGS)
			-- Create with settings.
		require
			settings_attached: a_settings /= Void
		do
			settings := a_settings
			create access_token.make_empty
			token_expires := 0
			create last_error.make_empty
			create json_parser
			create process_runner.make
		end

feature -- Access

	settings: SOCIAL_SETTINGS
			-- Configuration.

	access_token: STRING_8
			-- Current OAuth access token.

	token_expires: INTEGER_64
			-- Unix timestamp when token expires.

	last_error: STRING_32
			-- Last error message.

feature -- Status

	is_configured: BOOLEAN
			-- Are credentials configured?
		do
			Result := settings.has_reddit_credentials
		end

	has_valid_token: BOOLEAN
			-- Do we have a valid access token?
		local
			now: INTEGER_64
		do
			now := current_unix_time
			Result := not access_token.is_empty and token_expires > now
		end

	has_error: BOOLEAN
			-- Did last operation fail?
		do
			Result := not last_error.is_empty
		end

feature -- Authentication

	authenticate: BOOLEAN
			-- Get OAuth2 access token.
		local
			cmd: STRING_32
			output: STRING_32
			val: detachable SIMPLE_JSON_VALUE
		do
			clear_error

			if not is_configured then
				set_error ("Reddit credentials not configured")
				Result := False
			else
				-- Use curl to get access token
				create cmd.make (500)
				cmd.append_string_general ("curl -s -X POST -A %"")
				cmd.append_string_general (settings.reddit_user_agent)
				cmd.append_string_general ("%" -u %"")
				cmd.append (settings.reddit_client_id)
				cmd.append_string_general (":")
				cmd.append (settings.reddit_client_secret)
				cmd.append_string_general ("%" -d %"grant_type=client_credentials%" https://www.reddit.com/api/v1/access_token")

				output := execute_command (cmd)

				if output /= Void and then not output.is_empty then
					val := json_parser.parse (output)
					if attached val as jval and then jval.is_object then
						if attached jval.as_object.item ({STRING_32} "access_token") as tok and then tok.is_string then
							access_token := tok.as_string_32.to_string_8
							if attached jval.as_object.item ({STRING_32} "expires_in") as exp and then exp.is_number then
								token_expires := current_unix_time + exp.as_integer - 60
							else
								token_expires := current_unix_time + 3540
							end
							Result := True
						elseif attached jval.as_object.item ({STRING_32} "error") as err and then err.is_string then
							set_error ("Auth failed: " + err.as_string_32)
						end
					end
				else
					set_error ("No response from Reddit API")
				end
			end
		end

feature -- Search

	search (a_query: READABLE_STRING_GENERAL; a_subreddit: detachable READABLE_STRING_GENERAL; a_limit: INTEGER): ARRAYED_LIST [SOCIAL_OPPORTUNITY]
			-- Search Reddit for posts matching query.
		require
			query_not_empty: not a_query.is_empty
			valid_limit: a_limit > 0 and a_limit <= 100
		local
			cmd: STRING_32
			url: STRING_32
			output: STRING_32
			val: detachable SIMPLE_JSON_VALUE
			i: INTEGER
		do
			create Result.make (a_limit)
			clear_error

			if not ensure_authenticated then
				-- Error already set
			else
				-- Build search URL
				create url.make (200)
				if attached a_subreddit as sub then
					url.append_string_general ("https://oauth.reddit.com/r/")
					url.append_string_general (sub)
					url.append_string_general ("/search.json?q=")
				else
					url.append_string_general ("https://oauth.reddit.com/search.json?q=")
				end
				url.append_string_general (url_encode (a_query))
				url.append_string_general ("&limit=")
				url.append_string_general (a_limit.out)
				url.append_string_general ("&sort=new&t=week")

				create cmd.make (500)
				cmd.append_string_general ("curl -s -A %"")
				cmd.append_string_general (settings.reddit_user_agent)
				cmd.append_string_general ("%" -H %"Authorization: Bearer ")
				cmd.append_string_general (access_token)
				cmd.append_string_general ("%" %"")
				cmd.append (url)
				cmd.append_string_general ("%"")

				output := execute_command (cmd)

				if output /= Void and then not output.is_empty then
					val := json_parser.parse (output)
					if attached val as jval and then jval.is_object then
						if attached jval.as_object.item ({STRING_32} "data") as data_val and then data_val.is_object then
							if attached data_val.as_object.item ({STRING_32} "children") as children_val and then children_val.is_array then
								from i := 1 until i > children_val.as_array.count loop
									if attached children_val.as_array.item (i) as child and then child.is_object then
										if attached child.as_object.item ({STRING_32} "data") as post_data then
											if attached parse_post (post_data) as opp then
												Result.extend (opp)
											end
										end
									end
									i := i + 1
								end
							end
						elseif attached jval.as_object.item ({STRING_32} "error") as err and then err.is_string then
							set_error ("Search failed: " + err.as_string_32)
						end
					end
				end
			end
		end

	search_subreddits (a_subreddits: ARRAY [READABLE_STRING_GENERAL]; a_query: READABLE_STRING_GENERAL; a_limit_per: INTEGER): ARRAYED_LIST [SOCIAL_OPPORTUNITY]
			-- Search multiple subreddits.
		require
			has_subreddits: a_subreddits.count > 0
			query_not_empty: not a_query.is_empty
		do
			create Result.make (a_subreddits.count * a_limit_per)
			across a_subreddits as sub loop
				Result.append (search (a_query, sub, a_limit_per))
			end
		end

feature {NONE} -- Implementation

	json_parser: SIMPLE_JSON
			-- JSON parser.

	process_runner: SIMPLE_PROCESS
			-- Process executor.

	ensure_authenticated: BOOLEAN
			-- Make sure we have a valid token.
		do
			if has_valid_token then
				Result := True
			else
				Result := authenticate
			end
		end

	parse_post (a_data: SIMPLE_JSON_VALUE): detachable SOCIAL_OPPORTUNITY
			-- Parse a Reddit post into an opportunity.
		local
			title, url, snippet, selftext: STRING_32
			subreddit: STRING_32
			obj: SIMPLE_JSON_OBJECT
		do
			if a_data.is_object then
				obj := a_data.as_object

				if attached obj.item ({STRING_32} "title") as t and then t.is_string then
					title := t.as_string_32
				else
					title := {STRING_32} "Untitled"
				end

				if attached obj.item ({STRING_32} "permalink") as p and then p.is_string then
					url := {STRING_32} "https://www.reddit.com" + p.as_string_32
				else
					url := {STRING_32} ""
				end

				if attached obj.item ({STRING_32} "selftext") as st and then st.is_string then
					selftext := st.as_string_32
					if selftext.count > 500 then
						snippet := selftext.substring (1, 500) + {STRING_32} "..."
					else
						snippet := selftext
					end
				else
					snippet := {STRING_32} ""
				end

				if attached obj.item ({STRING_32} "subreddit") as sr and then sr.is_string then
					subreddit := sr.as_string_32
					title := {STRING_32} "[r/" + subreddit + {STRING_32} "] " + title
				end

				if not url.is_empty then
					create Result.make ((create {SOCIAL_PLATFORM}).Reddit, url, title)
					Result.set_snippet (snippet)
				end
			end
		end

	execute_command (a_command: STRING_32): detachable STRING_32
			-- Execute command and return output.
		do
			process_runner.execute (a_command)
			if process_runner.was_successful then
				Result := process_runner.last_output
			end
		end

	url_encode (a_string: READABLE_STRING_GENERAL): STRING_8
			-- URL encode a string.
		local
			i: INTEGER
			c: CHARACTER_32
		do
			create Result.make (a_string.count * 3)
			from i := 1 until i > a_string.count loop
				c := a_string.item (i)
				if c.is_alpha or c.is_digit then
					Result.append_character (c.to_character_8)
				elseif c = ' ' then
					Result.append_character ('+')
				else
					Result.append_character ('%%')
					Result.append (c.natural_32_code.to_hex_string.substring (7, 8))
				end
				i := i + 1
			end
		end

	current_unix_time: INTEGER_64
			-- Current time as Unix timestamp.
		local
			now: DATE_TIME
			epoch: DATE_TIME
		do
			create now.make_now_utc
			create epoch.make (1970, 1, 1, 0, 0, 0)
			Result := now.definite_duration (epoch).seconds_count
		end

	clear_error
			-- Clear last error.
		do
			create last_error.make_empty
		end

	set_error (a_msg: READABLE_STRING_GENERAL)
			-- Set error message.
		do
			last_error := a_msg.to_string_32
		end

invariant
	settings_attached: settings /= Void

end
