#+build linux
package snsvrno_log

import "base:runtime"
import "core:c"
import "core:c/libc"
import "core:log"
import "core:strings"
import "vendor:raylib"

raylib_connect :: proc() {
	raylib.SetTraceLogCallback(raylib_callback)
	log.logf(.Info, "Connected <vendor>{}</vendor> to logger", "raylib")
}

// callback function to connect raylib logging and intercept that into the global logging
// so we can output it correctly in the console, or save it to a file
raylib_callback :: proc "c" (msgType:raylib.TraceLogLevel, text:cstring, args: ^c.va_list) {
	context = runtime.default_context()
	context.logger = LOGGER

	s:[^]u8
	n:uint=200
	b:[200]u8
	s = raw_data(b[:])
	length := libc.vsnprintf(s, n, text, args)
	str := strings.string_from_ptr(s, int(length))

	type:log.Level
	switch msgType {
	case .DEBUG: type = .Debug
	case .WARNING: type = .Warning
	case .TRACE, .INFO, .ALL, .NONE : type = .Info
	case .FATAL: type = .Error
	case .ERROR: type = .Fatal
	}

	logc(type, "raylib", str)
}
