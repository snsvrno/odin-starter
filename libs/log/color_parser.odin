package snsvrno_log

import "core:strings"

ColorSectionCommands :: enum {
	Push, Pop, Write,
}

ColorSection :: struct {
	data:string,
	command:ColorSectionCommands,
}

color_parse_sections :: proc(text:string) -> []ColorSection {
	text:=text

	tokens:[dynamic]ColorSection
	for strings.rune_count(text) > 0 {
		before := strings.truncate_to_rune(text, '<')
		append(&tokens, ColorSection { data=before, command=.Write, })
		text = text[len(before)+1:]

		first_name := strings.truncate_to_rune(text, '>')
		push := false if first_name[0] == '/' else true
		append(&tokens, ColorSection {
			data = first_name if push else first_name[1:],
			command = .Push if push else .Pop,
		})
		text = text[len(first_name)+1:]
	}

	return tokens[:]
}
