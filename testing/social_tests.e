note
	description: "Tests for simple_social library"
	author: "Larry Rix"

class
	SOCIAL_TESTS

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		do
			print ("simple_social tests%N")
			test_opportunity_creation
			test_settings_defaults
			print ("All tests passed!%N")
		end

feature -- Tests

	test_opportunity_creation
			-- Test creating an opportunity.
		local
			opp: SOCIAL_OPPORTUNITY
			platform: SOCIAL_PLATFORM
		do
			create platform
			create opp.make (platform.Reddit, "https://reddit.com/r/test/1", "Test Post")
			assert ("has_url", not opp.url.is_empty)
			assert ("has_title", not opp.title.is_empty)
			print ("  test_opportunity_creation: passed%N")
		end

	test_settings_defaults
			-- Test settings with defaults.
		local
			settings: SOCIAL_SETTINGS
		do
			create settings.make
			assert ("has_default_port", settings.dashboard_port = 8080)
			assert ("has_keywords", settings.keywords.count > 0)
			print ("  test_settings_defaults: passed%N")
		end

feature {NONE} -- Helpers

	assert (a_tag: STRING; a_condition: BOOLEAN)
			-- Assert condition is true.
		require
			tag_not_empty: not a_tag.is_empty
		do
			if not a_condition then
				print ("FAILED: " + a_tag + "%N")
				(create {EXCEPTIONS}).die (1)
			end
		end

end
