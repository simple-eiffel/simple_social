note
	description: "[
		SOCIAL_SETTINGS - Configuration loaded from settings.json.

		Holds API credentials, SMTP settings, and preferences.
		All sensitive data stays in the private instance, not the library.
	]"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_SETTINGS

create
	make,
	make_from_file

feature {NONE} -- Initialization

	make
			-- Create with defaults.
		do
			create reddit_client_id.make_empty
			create reddit_client_secret.make_empty
			reddit_user_agent := "simple_social/1.0"
			create stackoverflow_api_key.make_empty
			create github_token.make_empty
			create devto_api_key.make_empty
			smtp_host := "localhost"
			smtp_port := 25
			smtp_from := "social@localhost"
			create email_to.make_empty
			dashboard_port := 8080
			scan_interval_minutes := 30
			create keywords.make (50)
			load_default_keywords
		end

	make_from_file (a_path: READABLE_STRING_GENERAL)
			-- Load settings from JSON file.
		require
			path_not_empty: not a_path.is_empty
		local
			f: PLAIN_TEXT_FILE
			content: STRING
			json: SIMPLE_JSON
			val: detachable SIMPLE_JSON_VALUE
		do
			make -- Start with defaults
			create f.make_with_name (a_path)
			if f.exists and f.is_readable then
				f.open_read
				f.read_stream (f.count)
				content := f.last_string
				f.close
				create json
				val := json.parse (content.to_string_32)
				if attached val as v then
					parse_settings (v)
				end
			end
			settings_path := a_path.to_string_32
		end

feature -- Reddit Settings

	reddit_client_id: STRING_32
	reddit_client_secret: STRING_32
	reddit_user_agent: STRING_8

	has_reddit_credentials: BOOLEAN
			-- Are Reddit API credentials configured?
		do
			Result := not reddit_client_id.is_empty and not reddit_client_secret.is_empty
		end

feature -- Stack Overflow Settings

	stackoverflow_api_key: STRING_32

	has_stackoverflow_key: BOOLEAN
		do
			Result := not stackoverflow_api_key.is_empty
		end

feature -- GitHub Settings

	github_token: STRING_32

	has_github_token: BOOLEAN
		do
			Result := not github_token.is_empty
		end

feature -- Dev.to Settings

	devto_api_key: STRING_32

	has_devto_key: BOOLEAN
		do
			Result := not devto_api_key.is_empty
		end

feature -- SMTP Settings

	smtp_host: STRING_8
	smtp_port: INTEGER
	smtp_from: STRING_8

feature -- Email Settings

	email_to: STRING_32

	has_email_configured: BOOLEAN
		do
			Result := not email_to.is_empty
		end

feature -- Dashboard Settings

	dashboard_port: INTEGER

feature -- Scan Settings

	scan_interval_minutes: INTEGER

feature -- Keywords

	keywords: ARRAYED_LIST [STRING_32]

feature -- Path

	settings_path: detachable STRING_32
			-- Path to settings file if loaded from file.

feature -- Modification

	add_keyword (a_keyword: READABLE_STRING_GENERAL)
			-- Add a keyword to search for.
		require
			not_empty: not a_keyword.is_empty
		do
			keywords.extend (a_keyword.to_string_32)
		end

	clear_keywords
			-- Remove all keywords.
		do
			keywords.wipe_out
		end

feature {NONE} -- Parsing

	parse_settings (a_val: SIMPLE_JSON_VALUE)
			-- Parse settings from JSON value.
		local
			obj, reddit, so, gh, dev, smtp: SIMPLE_JSON_OBJECT
			arr: SIMPLE_JSON_ARRAY
			i: INTEGER
		do
			if a_val.is_object then
				obj := a_val.as_object

				-- Reddit
				if attached obj.item ({STRING_32} "reddit") as reddit_val and then reddit_val.is_object then
					reddit := reddit_val.as_object
					if attached reddit.item ({STRING_32} "client_id") as s and then s.is_string then
						reddit_client_id := s.as_string_32
					end
					if attached reddit.item ({STRING_32} "client_secret") as s and then s.is_string then
						reddit_client_secret := s.as_string_32
					end
					if attached reddit.item ({STRING_32} "user_agent") as s and then s.is_string then
						reddit_user_agent := s.as_string_32.to_string_8
					end
				end

				-- Stack Overflow
				if attached obj.item ({STRING_32} "stackoverflow") as so_val and then so_val.is_object then
					so := so_val.as_object
					if attached so.item ({STRING_32} "api_key") as s and then s.is_string then
						stackoverflow_api_key := s.as_string_32
					end
				end

				-- GitHub
				if attached obj.item ({STRING_32} "github") as gh_val and then gh_val.is_object then
					gh := gh_val.as_object
					if attached gh.item ({STRING_32} "token") as s and then s.is_string then
						github_token := s.as_string_32
					end
				end

				-- Dev.to
				if attached obj.item ({STRING_32} "devto") as dev_val and then dev_val.is_object then
					dev := dev_val.as_object
					if attached dev.item ({STRING_32} "api_key") as s and then s.is_string then
						devto_api_key := s.as_string_32
					end
				end

				-- SMTP
				if attached obj.item ({STRING_32} "smtp") as smtp_val and then smtp_val.is_object then
					smtp := smtp_val.as_object
					if attached smtp.item ({STRING_32} "host") as s and then s.is_string then
						smtp_host := s.as_string_32.to_string_8
					end
					if attached smtp.item ({STRING_32} "port") as n and then n.is_number then
						smtp_port := n.as_integer.to_integer_32
					end
					if attached smtp.item ({STRING_32} "from") as s and then s.is_string then
						smtp_from := s.as_string_32.to_string_8
					end
				end

				-- Email
				if attached obj.item ({STRING_32} "email_to") as s and then s.is_string then
					email_to := s.as_string_32
				end

				-- Dashboard
				if attached obj.item ({STRING_32} "dashboard_port") as n and then n.is_number then
					dashboard_port := n.as_integer.to_integer_32
				end

				-- Scan interval
				if attached obj.item ({STRING_32} "scan_interval_minutes") as n and then n.is_number then
					scan_interval_minutes := n.as_integer.to_integer_32
				end

				-- Keywords
				if attached obj.item ({STRING_32} "keywords") as arr_val and then arr_val.is_array then
					arr := arr_val.as_array
					keywords.wipe_out
					from i := 1 until i > arr.count loop
						if attached arr.item (i) as kw and then kw.is_string then
							keywords.extend (kw.as_string_32)
						end
						i := i + 1
					end
				end
			end
		end

	load_default_keywords
			-- Load default keywords for entire Simple Eiffel ecosystem.
		do
			-- Core Eiffel concepts
			keywords.extend ({STRING_32} "Eiffel programming language")
			keywords.extend ({STRING_32} "Design by Contract")
			keywords.extend ({STRING_32} "DbC programming")
			keywords.extend ({STRING_32} "precondition postcondition invariant")
			keywords.extend ({STRING_32} "void safety programming")
			keywords.extend ({STRING_32} "null safety language")
			keywords.extend ({STRING_32} "SCOOP concurrency")

			-- simple_speech / transcription
			keywords.extend ({STRING_32} "offline transcription tool")
			keywords.extend ({STRING_32} "local speech to text")
			keywords.extend ({STRING_32} "whisper.cpp transcription")
			keywords.extend ({STRING_32} "self-hosted transcription")
			keywords.extend ({STRING_32} "alternative to Otter.ai")
			keywords.extend ({STRING_32} "video captioning software")
			keywords.extend ({STRING_32} "auto chapter detection video")
			keywords.extend ({STRING_32} "privacy speech to text")

			-- simple_cairo / graphics
			keywords.extend ({STRING_32} "cairo graphics programming")
			keywords.extend ({STRING_32} "vector graphics library")
			keywords.extend ({STRING_32} "PDF generation library")

			-- simple_http / web
			keywords.extend ({STRING_32} "lightweight http server")
			keywords.extend ({STRING_32} "embedded web server")

			-- simple_sql / database
			keywords.extend ({STRING_32} "sqlite wrapper library")
			keywords.extend ({STRING_32} "simple database library")

			-- simple_ai_client / AI
			keywords.extend ({STRING_32} "local AI ollama")
			keywords.extend ({STRING_32} "multi-provider AI client")
			keywords.extend ({STRING_32} "ollama programming")

			-- General safety/correctness
			keywords.extend ({STRING_32} "memory safe language")
			keywords.extend ({STRING_32} "formal methods programming")
			keywords.extend ({STRING_32} "contract-based programming")
			keywords.extend ({STRING_32} "software correctness")
			keywords.extend ({STRING_32} "safe concurrency")
		end

invariant
	valid_port: smtp_port > 0 and smtp_port < 65536
	valid_dashboard_port: dashboard_port > 0 and dashboard_port < 65536
	valid_interval: scan_interval_minutes > 0

end
