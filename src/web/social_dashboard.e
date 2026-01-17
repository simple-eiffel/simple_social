note
	description: "Dashboard generator for social monitoring and Eiffel resources"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_DASHBOARD

create
	make

feature {NONE} -- Initialization

	make (a_database: SOCIAL_DATABASE)
			-- Create dashboard with database.
		require
			database_attached: a_database /= Void
		do
			database := a_database
		end

feature -- Access

	database: SOCIAL_DATABASE
			-- Social database.

feature -- Operations

	generate_to_folder (a_folder: STRING)
			-- Generate dashboard HTML files to folder.
		local
			home_file, resources_file, opportunities_file: PLAIN_TEXT_FILE
		do
			-- Generate home page
			create home_file.make_create_read_write (a_folder + "/index.html")
			home_file.put_string (render_home_page)
			home_file.close
			io.put_string ("Generated: " + a_folder + "/index.html%N")

			-- Generate resources page
			create resources_file.make_create_read_write (a_folder + "/resources.html")
			resources_file.put_string (render_resources_page)
			resources_file.close
			io.put_string ("Generated: " + a_folder + "/resources.html%N")

			-- Generate opportunities page
			create opportunities_file.make_create_read_write (a_folder + "/opportunities.html")
			opportunities_file.put_string (render_opportunities_page)
			opportunities_file.close
			io.put_string ("Generated: " + a_folder + "/opportunities.html%N")
		end

	generate_json_api (a_folder: STRING)
			-- Generate JSON API files.
		local
			stats_file, resources_file: PLAIN_TEXT_FILE
		do
			create stats_file.make_create_read_write (a_folder + "/api_stats.json")
			stats_file.put_string (render_stats_json)
			stats_file.close
			io.put_string ("Generated: " + a_folder + "/api_stats.json%N")

			create resources_file.make_create_read_write (a_folder + "/api_resources.json")
			resources_file.put_string (render_resources_json)
			resources_file.close
			io.put_string ("Generated: " + a_folder + "/api_resources.json%N")
		end

feature {NONE} -- JSON Rendering

	render_stats_json: STRING
			-- JSON statistics.
		do
			create Result.make (200)
			Result.append ("{")
			Result.append ("%"opportunities%": " + database.opportunity_count.out + ",")
			Result.append ("%"actionable%": " + database.actionable_count.out + ",")
			Result.append ("%"pending_drafts%": " + database.pending_draft_count.out + ",")
			Result.append ("%"unread_replies%": " + database.unread_reply_count.out + ",")
			Result.append ("%"resources%": " + database.resource_count.out)
			Result.append ("}")
		end

	render_resources_json: STRING
			-- JSON resources.
		local
			resources: like database.get_all_resources
			first: BOOLEAN
		do
			resources := database.get_all_resources
			create Result.make (5000)
			Result.append ("[")
			first := True
			across resources as r loop
				if not first then Result.append (",") end
				Result.append ("{")
				Result.append ("%"id%":" + r.id.out + ",")
				Result.append ("%"url%":%"" + escape_json (r.url.to_string_8) + "%",")
				Result.append ("%"title%":%"" + escape_json (r.title.to_string_8) + "%",")
				Result.append ("%"description%":%"" + escape_json (r.description.to_string_8) + "%",")
				Result.append ("%"category%":%"" + r.category.to_string_8 + "%",")
				Result.append ("%"quality%":" + r.quality.out)
				Result.append ("}")
				first := False
			end
			Result.append ("]")
		end

feature {NONE} -- HTML Rendering

	render_home_page: STRING
			-- Render home dashboard.
		do
			create Result.make (2000)
			Result.append (page_header ("Social Dashboard"))
			Result.append ("<div class=%"container%">")
			Result.append ("<h1>Simple Social Dashboard</h1>")
			Result.append ("<p>Monitor social media for Eiffel-related discussions and opportunities.</p>")
			Result.append ("<div class=%"stats%">")
			Result.append ("<div class=%"stat-card%"><h3>" + database.opportunity_count.out + "</h3><p>Opportunities</p></div>")
			Result.append ("<div class=%"stat-card%"><h3>" + database.actionable_count.out + "</h3><p>Actionable</p></div>")
			Result.append ("<div class=%"stat-card%"><h3>" + database.pending_draft_count.out + "</h3><p>Pending Drafts</p></div>")
			Result.append ("<div class=%"stat-card%"><h3>" + database.resource_count.out + "</h3><p>Resources</p></div>")
			Result.append ("</div>")
			Result.append ("<nav>")
			Result.append ("<a href=%"opportunities.html%" class=%"btn%">View Opportunities</a>")
			Result.append ("<a href=%"resources.html%" class=%"btn%">Browse Eiffel Resources</a>")
			Result.append ("</nav>")
			Result.append ("</div>")
			Result.append (page_footer)
		end

	render_opportunities_page: STRING
			-- Render opportunities list.
		local
			opps: ARRAYED_LIST [SOCIAL_OPPORTUNITY]
		do
			opps := database.recent_opportunities (50)
			create Result.make (5000)
			Result.append (page_header ("Opportunities"))
			Result.append ("<div class=%"container%">")
			Result.append ("<h1>Social Opportunities</h1>")
			Result.append ("<p>Found " + opps.count.out + " social media opportunities to engage with.</p>")
			if opps.is_empty then
				Result.append ("<p class=%"empty%">No opportunities yet. Run the scout to scan social media.</p>")
			else
				Result.append ("<ul class=%"opportunity-list%">")
				across opps as opp loop
					Result.append ("<li>")
					Result.append ("<a href=%"" + opp.url.to_string_8 + "%" target=%"_blank%">" + escape_html (opp.title.to_string_8) + "</a>")
					Result.append ("<span class=%"score%">" + (opp.relevance_score * 100).truncated_to_integer.out + "%%</span>")
					if not opp.snippet.is_empty then
						Result.append ("<p class=%"snippet%">" + escape_html (opp.snippet.to_string_8.substring (1, opp.snippet.count.min (200))) + "...</p>")
					end
					Result.append ("</li>")
				end
				Result.append ("</ul>")
			end
			Result.append ("<a href=%"index.html%" class=%"back%">Back to Dashboard</a>")
			Result.append ("</div>")
			Result.append (page_footer)
		end

	render_resources_page: STRING
			-- Render resources page with all Eiffel resources by category.
		local
			resources: like database.get_all_resources
			categories: ARRAYED_LIST [STRING_32]
			current_cat: STRING_32
		do
			resources := database.get_all_resources
			categories := database.resource_categories
			create Result.make (15000)
			Result.append (page_header ("Eiffel Resources"))
			Result.append ("<div class=%"container%">")
			Result.append ("<h1>Eiffel Programming Resources</h1>")
			Result.append ("<p>" + resources.count.out + " curated resources for learning and mastering Eiffel.</p>")

			-- Table of contents
			Result.append ("<div class=%"toc%">")
			Result.append ("<strong>Categories:</strong> ")
			across categories as cat loop
				Result.append ("<a href=%"#" + cat.to_string_8 + "%">" + capitalize (cat.to_string_8) + "</a> ")
			end
			Result.append ("</div>")

			-- Resources by category
			current_cat := ""
			across resources as r loop
				if not r.category.same_string (current_cat) then
					if not current_cat.is_empty then
						Result.append ("</ul>")
					end
					Result.append ("<h2 id=%"" + r.category.to_string_8 + "%">" + capitalize (r.category.to_string_8) + "</h2>")
					Result.append ("<ul class=%"resource-list%">")
					current_cat := r.category
				end
				Result.append ("<li>")
				Result.append ("<a href=%"" + r.url.to_string_8 + "%" target=%"_blank%">" + escape_html (r.title.to_string_8) + "</a>")
				if not r.description.is_empty then
					Result.append ("<p>" + escape_html (r.description.to_string_8) + "</p>")
				end
				Result.append ("</li>")
			end
			if not current_cat.is_empty then
				Result.append ("</ul>")
			end

			Result.append ("<a href=%"index.html%" class=%"back%">Back to Dashboard</a>")
			Result.append ("</div>")
			Result.append (page_footer)
		end

	page_header (a_title: STRING): STRING
			-- HTML page header with CSS.
		do
			create Result.make (2000)
			Result.append ("<!DOCTYPE html>%N<html lang=%"en%">%N<head>%N")
			Result.append ("<meta charset=%"UTF-8%">%N")
			Result.append ("<meta name=%"viewport%" content=%"width=device-width, initial-scale=1%">%N")
			Result.append ("<title>" + a_title + " - Simple Social</title>%N")
			Result.append ("<style>%N")
			Result.append (css_styles)
			Result.append ("</style>%N</head>%N<body>%N")
		end

	page_footer: STRING
			-- HTML page footer.
		do
			create Result.make (100)
			Result.append ("<footer><p>Generated by Simple Social | Powered by Eiffel</p></footer>%N")
			Result.append ("</body>%N</html>%N")
		end

	css_styles: STRING
			-- CSS stylesheet.
		do
			create Result.make (2000)
			Result.append ("*{box-sizing:border-box;margin:0;padding:0}%N")
			Result.append ("body{font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;line-height:1.6;background:#f0f4f8;color:#1a202c;min-height:100vh}%N")
			Result.append (".container{max-width:1000px;margin:0 auto;padding:40px 20px}%N")
			Result.append ("h1{color:#2d3748;font-size:2.5em;margin-bottom:10px;border-bottom:3px solid #4a90d9;padding-bottom:15px}%N")
			Result.append ("h2{color:#4a90d9;font-size:1.5em;margin:40px 0 20px;padding-bottom:10px;border-bottom:1px solid #e2e8f0}%N")
			Result.append ("p{color:#4a5568;margin-bottom:20px}%N")
			Result.append (".stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:20px;margin:40px 0}%N")
			Result.append (".stat-card{background:linear-gradient(135deg,#4a90d9,#357abd);color:#fff;padding:30px;border-radius:12px;text-align:center;box-shadow:0 4px 15px rgba(74,144,217,0.3)}%N")
			Result.append (".stat-card h3{font-size:3em;margin-bottom:5px}%N")
			Result.append (".stat-card p{color:rgba(255,255,255,0.9);font-size:1.1em;margin:0}%N")
			Result.append ("nav{margin:30px 0;display:flex;gap:15px;flex-wrap:wrap}%N")
			Result.append (".btn{display:inline-block;background:#4a90d9;color:#fff;padding:15px 30px;text-decoration:none;border-radius:8px;font-weight:600;transition:all 0.3s}%N")
			Result.append (".btn:hover{background:#357abd;transform:translateY(-2px);box-shadow:0 4px 12px rgba(74,144,217,0.4)}%N")
			Result.append ("a{color:#4a90d9;text-decoration:none}%N")
			Result.append ("a:hover{text-decoration:underline}%N")
			Result.append (".toc{background:#e9f0f7;padding:20px;border-radius:8px;margin:20px 0}%N")
			Result.append (".toc a{margin-right:15px}%N")
			Result.append ("ul{list-style:none}%N")
			Result.append (".resource-list li,.opportunity-list li{background:#fff;padding:20px;margin:15px 0;border-radius:8px;border-left:4px solid #4a90d9;box-shadow:0 2px 8px rgba(0,0,0,0.08)}%N")
			Result.append (".resource-list li:hover,.opportunity-list li:hover{box-shadow:0 4px 12px rgba(0,0,0,0.12);transform:translateY(-2px);transition:all 0.2s}%N")
			Result.append (".resource-list li a,.opportunity-list li a{font-size:1.1em;font-weight:600}%N")
			Result.append (".resource-list li p,.snippet{color:#718096;font-size:0.95em;margin-top:8px}%N")
			Result.append (".score{float:right;background:#48bb78;color:#fff;padding:4px 12px;border-radius:20px;font-size:0.85em;font-weight:600}%N")
			Result.append (".empty{background:#fef3c7;padding:30px;border-radius:8px;text-align:center;color:#92400e}%N")
			Result.append (".back{display:inline-block;margin-top:30px;color:#4a90d9;font-weight:600}%N")
			Result.append ("footer{text-align:center;padding:40px;color:#a0aec0;font-size:0.9em}%N")
		end

feature {NONE} -- Helpers

	escape_html (a_text: STRING): STRING
			-- Escape HTML special characters.
		do
			Result := a_text.twin
			Result.replace_substring_all ("&", "&amp;")
			Result.replace_substring_all ("<", "&lt;")
			Result.replace_substring_all (">", "&gt;")
			Result.replace_substring_all ("%"", "&quot;")
		end

	escape_json (a_text: STRING): STRING
			-- Escape JSON special characters.
		do
			Result := a_text.twin
			Result.replace_substring_all ("\", "\\")
			Result.replace_substring_all ("%"", "\%"")
			Result.replace_substring_all ("%N", "\n")
			Result.replace_substring_all ("%R", "\r")
			Result.replace_substring_all ("%T", "\t")
		end

	capitalize (a_text: STRING): STRING
			-- Capitalize first letter.
		do
			Result := a_text.twin
			if not Result.is_empty then
				Result.put (Result.item (1).upper, 1)
			end
		end

invariant
	database_attached: database /= Void

end
