note
	description: "[
		SOCIAL_ANALYZER - AI-powered relevance scoring and draft generation.

		Uses simple_ai_client to analyze opportunities and
		generate response drafts.
	]"
	author: "Larry Rix"
	date: "$Date$"

class
	SOCIAL_ANALYZER

create
	make

feature {NONE} -- Initialization

	make
			-- Create analyzer.
		do
			create ai_client.make
			create last_error.make_empty
		end

feature -- Access

	ai_client: SIMPLE_AI_QUICK
	last_error: STRING_32

feature -- Status

	has_error: BOOLEAN
		do
			Result := not last_error.is_empty
		end

feature -- Analysis

	score_relevance (a_opp: SOCIAL_OPPORTUNITY): REAL_64
			-- Score how relevant an opportunity is (0.0 to 1.0).
		local
			prompt: STRING_8
			response: STRING
			score: REAL_64
		do
			clear_error
			create prompt.make (2000)
			prompt.append_string ("Rate the relevance of this discussion for promoting:%N")
			prompt.append_string ("1. Eiffel programming language and Design by Contract%N")
			prompt.append_string ("2. simple_speech - a local offline speech-to-text tool%N%N")
			prompt.append_string ("Title: ")
			prompt.append_string (a_opp.title.to_string_8)
			prompt.append_string ("%N%NContent snippet:%N")
			prompt.append_string (a_opp.snippet.to_string_8)
			prompt.append_string ("%N%NRespond with ONLY a number from 0 to 100 representing relevance percentage.")
			prompt.append_string ("%N0 = completely irrelevant%N50 = somewhat relevant%N100 = perfect match")

			response := ai_client.ask (prompt)

			if ai_client.has_error then
				set_error (ai_client.last_error)
				Result := 0.5 -- Default to medium if AI fails
			else
				-- Parse score from response
				response.adjust
				if response.is_integer then
					score := response.to_integer.to_double / 100.0
					Result := score.max (0.0).min (1.0)
				else
					-- Try to extract number
					Result := extract_score_8 (response)
				end
			end

			a_opp.set_relevance (Result)
		ensure
			valid_score: Result >= 0.0 and Result <= 1.0
		end

	generate_draft (a_opp: SOCIAL_OPPORTUNITY): detachable SOCIAL_DRAFT
			-- Generate a response draft for an opportunity.
		local
			prompt: STRING_8
			response: STRING
		do
			clear_error
			create prompt.make (3000)
			prompt.append_string ("You are helping promote the Simple Eiffel ecosystem.%N%N")
			prompt.append_string ("Context about what we offer:%N")
			prompt.append_string ("- Eiffel: A programming language with built-in Design by Contract (preconditions, postconditions, invariants)%N")
			prompt.append_string ("- Void safety (null safety) built into the type system%N")
			prompt.append_string ("- SCOOP for safe concurrency%N")
			prompt.append_string ("- simple_speech: Local-first speech-to-text CLI tool, offline, privacy-focused%N")
			prompt.append_string ("- Uses whisper.cpp for transcription%N")
			prompt.append_string ("- Features: auto-chapters, caption embedding, batch processing%N%N")
			prompt.append_string ("Write a helpful, non-promotional response to this discussion:%N%N")
			prompt.append_string ("Platform: ")
			prompt.append_string (a_opp.platform_name.to_string_8)
			prompt.append_string ("%NTitle: ")
			prompt.append_string (a_opp.title.to_string_8)
			prompt.append_string ("%N%NContent:%N")
			prompt.append_string (a_opp.snippet.to_string_8)
			prompt.append_string ("%N%NGuidelines:%N")
			prompt.append_string ("- Be genuinely helpful, not salesy%N")
			prompt.append_string ("- Only mention our tools if they solve the person's actual problem%N")
			prompt.append_string ("- Match the tone of the platform (Reddit is casual, SO is technical)%N")
			prompt.append_string ("- Keep it concise%N")
			prompt.append_string ("- Include relevant links only if truly helpful%N")
			prompt.append_string ("- If our tools aren't relevant, just provide helpful advice%N")

			response := ai_client.ask (prompt)

			if ai_client.has_error then
				set_error (ai_client.last_error)
			else
				if not response.is_empty then
					create Result.make (a_opp.id, response.to_string_32)
				end
			end
		end

	regenerate_draft (a_draft: SOCIAL_DRAFT; a_opp: SOCIAL_OPPORTUNITY; a_instruction: detachable READABLE_STRING_GENERAL)
			-- Regenerate draft with optional instruction.
		local
			prompt: STRING_8
			response: STRING
		do
			clear_error
			create prompt.make (3000)
			prompt.append_string ("Rewrite this response draft")
			if attached a_instruction as inst then
				prompt.append_string (" with this guidance: ")
				prompt.append_string (inst.to_string_8)
			else
				prompt.append_string (" to be better")
			end
			prompt.append_string (".%N%NOriginal context:%N")
			prompt.append_string ("Title: ")
			prompt.append_string (a_opp.title.to_string_8)
			prompt.append_string ("%N%NCurrent draft:%N")
			prompt.append_string (a_draft.content.to_string_8)
			prompt.append_string ("%N%NProvide only the rewritten response, no explanation.")

			response := ai_client.ask (prompt)

			if ai_client.has_error then
				set_error (ai_client.last_error)
			else
				if not response.is_empty then
					a_draft.regenerate (response.to_string_32)
				end
			end
		end

	generate_reply (a_reply: SOCIAL_REPLY; a_context: READABLE_STRING_GENERAL): detachable STRING_32
			-- Generate a response to a reply.
		local
			prompt: STRING_8
			response: STRING
		do
			clear_error
			create prompt.make (2000)
			prompt.append_string ("Someone replied to your previous comment. Write a follow-up response.%N%N")
			prompt.append_string ("Context of the original discussion:%N")
			prompt.append_string (a_context.to_string_8)
			prompt.append_string ("%N%NTheir reply:%N")
			prompt.append_string ("@")
			prompt.append_string (a_reply.author.to_string_8)
			prompt.append_string (": ")
			prompt.append_string (a_reply.content.to_string_8)
			prompt.append_string ("%N%NGuidelines:%N")
			prompt.append_string ("- Be conversational and friendly%N")
			prompt.append_string ("- Address their specific points%N")
			prompt.append_string ("- Keep it concise%N")
			prompt.append_string ("- If they're being hostile, stay professional%N")

			response := ai_client.ask (prompt)

			if ai_client.has_error then
				set_error (ai_client.last_error)
			else
				if not response.is_empty then
					Result := response.to_string_32
				end
			end
		end

feature {NONE} -- Implementation

	extract_score_8 (a_response: STRING): REAL_64
			-- Try to extract a numeric score from AI response.
		local
			i: INTEGER
			num_str: STRING_8
			c: CHARACTER_8
		do
			create num_str.make (5)
			from i := 1 until i > a_response.count or num_str.count >= 3 loop
				c := a_response.item (i)
				if c.is_digit then
					num_str.append_character (c)
				elseif not num_str.is_empty then
					-- Stop at first non-digit after finding digits
					i := a_response.count -- Exit loop
				end
				i := i + 1
			end

			if num_str.is_integer then
				Result := num_str.to_integer.to_double / 100.0
				Result := Result.max (0.0).min (1.0)
			else
				Result := 0.5 -- Default
			end
		end

	clear_error
		do
			create last_error.make_empty
		end

	set_error (a_msg: READABLE_STRING_GENERAL)
		do
			last_error := a_msg.to_string_32
		end

end
