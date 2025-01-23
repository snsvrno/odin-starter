 #+build windows, linux, darwin
package snsvrno_log

import "core:fmt"

out :: proc(text:string) {
	fmt.println(text)
}

outf :: proc(format:string, params:..any) {
	fmt.printfln(format, ..params)
}
