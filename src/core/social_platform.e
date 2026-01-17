note
	description: "Platform identifiers for social media sources"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_PLATFORM

feature -- Constants

	Reddit: INTEGER = 1
	Stack_overflow: INTEGER = 2
	Hacker_news: INTEGER = 3
	Github_discussions: INTEGER = 4
	Devto: INTEGER = 5

feature -- Query

	name (a_platform: INTEGER): STRING_8
			-- Human-readable name for platform.
		require
			valid_platform: is_valid (a_platform)
		do
			inspect a_platform
			when Reddit then Result := "Reddit"
			when Stack_overflow then Result := "Stack Overflow"
			when Hacker_news then Result := "Hacker News"
			when Github_discussions then Result := "GitHub Discussions"
			when Devto then Result := "Dev.to"
			else
				Result := "Unknown"
			end
		ensure
			result_not_empty: not Result.is_empty
		end

	icon (a_platform: INTEGER): STRING_8
			-- Short icon/prefix for platform.
		require
			valid_platform: is_valid (a_platform)
		do
			inspect a_platform
			when Reddit then Result := "[R]"
			when Stack_overflow then Result := "[SO]"
			when Hacker_news then Result := "[HN]"
			when Github_discussions then Result := "[GH]"
			when Devto then Result := "[DEV]"
			else
				Result := "[?]"
			end
		ensure
			result_not_empty: not Result.is_empty
		end

	is_valid (a_platform: INTEGER): BOOLEAN
			-- Is this a valid platform identifier?
		do
			Result := a_platform >= Reddit and a_platform <= Devto
		end

	all_platforms: ARRAYED_LIST [INTEGER]
			-- List of all platform identifiers.
		once
			create Result.make (5)
			Result.extend (Reddit)
			Result.extend (Stack_overflow)
			Result.extend (Hacker_news)
			Result.extend (Github_discussions)
			Result.extend (Devto)
		ensure
			result_attached: Result /= Void
			has_all: Result.count = 5
		end

end
