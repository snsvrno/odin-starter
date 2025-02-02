package snsvrno_log

import "core:encoding/ansi"
import "core:fmt"

Color :: enum {
	None,
	Red, Green, Blue, Cyan, Magenta, Yellow, White, Black,
	BrRed, BrGreen, BrBlue, BrCyan, BrMagenta, BrYellow, BrWhite, BrBlack,
}

ColorMods :: enum {
	Bold, Underline, Italic, UnderlineDouble,
}

when ODIN_OS == .Freestanding {
	COLORIZE:bool=false
} else {
	COLORIZE:bool=true
}

colors_ansi_paint :: proc(text:string, fg:Color = .None, bg:Color = .None, mod:bit_set[ColorMods] = nil) -> string {
	codes:string

	switch fg {
	case .None:
	case .Red: codes = colors_ansi_add_code(codes, ansi.FG_RED)
	case .Green: codes = colors_ansi_add_code(codes, ansi.FG_GREEN)
	case .Blue: codes = colors_ansi_add_code(codes, ansi.FG_BLUE)
	case .Cyan: codes = colors_ansi_add_code(codes, ansi.FG_CYAN)
	case .Magenta: codes = colors_ansi_add_code(codes, ansi.FG_MAGENTA)
	case .Yellow: codes = colors_ansi_add_code(codes, ansi.FG_YELLOW)
	case .White: codes = colors_ansi_add_code(codes, ansi.FG_WHITE)
	case .Black: codes = colors_ansi_add_code(codes, ansi.FG_BLACK)
	case .BrRed: codes = colors_ansi_add_code(codes, ansi.FG_BRIGHT_RED)
	case .BrGreen: codes = colors_ansi_add_code(codes, ansi.FG_BRIGHT_GREEN)
	case .BrBlue: codes = colors_ansi_add_code(codes, ansi.FG_BRIGHT_BLUE)
	case .BrCyan: codes = colors_ansi_add_code(codes, ansi.FG_BRIGHT_CYAN)
	case .BrMagenta: codes = colors_ansi_add_code(codes, ansi.FG_BRIGHT_MAGENTA)
	case .BrYellow: codes = colors_ansi_add_code(codes, ansi.FG_BRIGHT_YELLOW)
	case .BrWhite: codes = colors_ansi_add_code(codes, ansi.FG_BRIGHT_WHITE)
	case .BrBlack: codes = colors_ansi_add_code(codes, ansi.FG_BRIGHT_BLACK)
	}

	switch bg {
	case .None:
	case .Red: codes = colors_ansi_add_code(codes, ansi.BG_RED)
	case .Green: codes = colors_ansi_add_code(codes, ansi.BG_GREEN)
	case .Blue: codes = colors_ansi_add_code(codes, ansi.BG_BLUE)
	case .Cyan: codes = colors_ansi_add_code(codes, ansi.BG_CYAN)
	case .Magenta: codes = colors_ansi_add_code(codes, ansi.BG_MAGENTA)
	case .Yellow: codes = colors_ansi_add_code(codes, ansi.BG_YELLOW)
	case .White: codes = colors_ansi_add_code(codes, ansi.BG_WHITE)
	case .Black: codes = colors_ansi_add_code(codes, ansi.BG_BLACK)
	case .BrRed: codes = colors_ansi_add_code(codes, ansi.BG_BRIGHT_RED)
	case .BrGreen: codes = colors_ansi_add_code(codes, ansi.BG_BRIGHT_GREEN)
	case .BrBlue: codes = colors_ansi_add_code(codes, ansi.BG_BRIGHT_BLUE)
	case .BrCyan: codes = colors_ansi_add_code(codes, ansi.BG_BRIGHT_CYAN)
	case .BrMagenta: codes = colors_ansi_add_code(codes, ansi.BG_BRIGHT_MAGENTA)
	case .BrYellow: codes = colors_ansi_add_code(codes, ansi.BG_BRIGHT_YELLOW)
	case .BrWhite: codes = colors_ansi_add_code(codes, ansi.BG_BRIGHT_WHITE)
	case .BrBlack: codes = colors_ansi_add_code(codes, ansi.BG_BRIGHT_BLACK)
	}

	if .Bold in mod { codes = fmt.aprintf("{0};{1}", codes, ansi.BOLD) }
	if .Underline in mod { codes = fmt.aprintf("{0};{1}", codes, ansi.UNDERLINE) }
	if .UnderlineDouble in mod { codes = fmt.aprintf("{0};{1}", codes, ansi.UNDERLINE_DOUBLE) }
	if .Italic in mod { codes = fmt.aprintf("{0};{1}", codes, ansi.ITALIC) }

	return fmt.aprintf(ansi.CSI + "{0}" + ansi.SGR + "{1}" + ansi.CSI + ansi.RESET + ansi.SGR, codes, text)
}

// dumb function to make it simpler when adding multiple ansi things,
// so we don't need to think too hard about if we need a ";" or not.
colors_ansi_add_code :: proc(existing:string, new_string:string) -> string {
	if len(existing) > 0 {
		return fmt.aprintf("{0};{1}", existing, new_string)
	} else { return new_string }
}

// takes a string with some kind of markdown, processes it and then colors it
// using ansi color codes

colors_to_ansi :: proc(text:string) -> string {
	sections:=color_parse_sections(text)
	
	// executes the command sections in order to make the requested text
	rendered_text:string
	style_stack:[dynamic]string
	defer delete(style_stack)

	for cmd in sections {
		switch cmd.command {
		case .Write:
			rend := cmd.data
			if len(style_stack) > 0 {
				rend = styles_apply(style_stack[len(style_stack)-1], rend)
			}
			rendered_text = fmt.aprintf("{0}{1}", rendered_text, rend)
		case .Push:
			if COLORIZE do append(&style_stack, cmd.data)
		case .Pop:
			if COLORIZE {
				last_style := pop(&style_stack)
				if last_style != cmd.data {
					outf("error, was expecting closing for {0} but got {1}", last_style, cmd.data)
					outf("  {}", text)
				}
			}
		}
	}

	return rendered_text

}
