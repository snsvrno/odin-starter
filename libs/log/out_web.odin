#+build wasm32
package snsvrno_log

import "core:c"
import "core:strings"
import "core:fmt"

@(default_calling_convention = "c")
foreign {
	puts :: proc(buffer: cstring) -> c.int ---
}

out :: proc(text:string) {
	puts(strings.clone_to_cstring(text))
}

outf :: proc(format:string, params:..any) {
	text := fmt.caprintfln(format, ..params)
	puts(text)
}
