note
	description: "Command-line interface for social monitoring"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_CLI

create
	make

feature {NONE} -- Initialization

	make
			-- Run CLI.
		do
			io.put_string ("simple_social CLI - Use 'social_cli --help' for usage%N")
		end

end
