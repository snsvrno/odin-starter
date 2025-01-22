package shared

styles_apply :: proc(style:string, text:string) -> string {
	switch style {

	case "info-block": return colors_ansi_paint(text, .Black, .BrBlack, {.Bold})
	case "info": return colors_ansi_paint(text, .BrBlack)
	case "debug-block": return colors_ansi_paint(text, .BrWhite, .Blue, {.Bold})
	case "debug": return colors_ansi_paint(text, .Blue)
	case "warn-block": return colors_ansi_paint(text, .BrWhite, .Yellow, {.Bold})
	case "warn": return colors_ansi_paint(text, .Yellow)
	case "fatal-block": return colors_ansi_paint(text, .BrMagenta, .Red, {.Bold})
	case "fatal": return colors_ansi_paint(text, .Magenta)
	case "err-block": return colors_ansi_paint(text, .BrWhite, .Red, {.Bold})
	case "err": return colors_ansi_paint(text, .Red)

	case "game_name": return colors_ansi_paint(text, .Yellow, .None, { .Bold, .Italic })
	case "game_version": return colors_ansi_paint(text, .BrCyan)
	case "build_artifact": return colors_ansi_paint(text, .Green)
	case "build_time": return colors_ansi_paint(text, .Red)
	case "vendor": return colors_ansi_paint(text, .Cyan, .None, { .Underline })
	case "title": return colors_ansi_paint(text, .BrMagenta, .None, { .Bold })

	case "number": return colors_ansi_paint(text, .Green)
	case "bool": return colors_ansi_paint(text, .Magenta)
	case "string": return colors_ansi_paint(text, .Red)
	case "key": return colors_ansi_paint(text, .Magenta, .None, { .Underline })
	case "value": return colors_ansi_paint(text, .Yellow, .None, { .Italic })
	case "path": return colors_ansi_paint(text, .Blue, .None, { .Underline, .Italic })

	case "context": return colors_ansi_paint(text, .Black, .White, { .Bold })

	case: return colors_ansi_paint(style, .BrRed, .Green, {.Italic})
	}
}
