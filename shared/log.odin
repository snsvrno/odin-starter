package shared

import "base:runtime"
import "core:c"
import "core:c/libc"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:encoding/ansi"
import "vendor:raylib"

LOGGER: runtime.Logger

// custom logger function
log_logging_proc :: proc(data: rawptr, level: runtime.Logger_Level, text: string, options: bit_set[runtime.Logger_Option], location := #caller_location) {

	switch level {
	case .Info: fmt.println(colors_to_ansi(fmt.aprintf("<info-block> I </info-block> <info>{0}</info>", text)))
	case .Debug: fmt.println(colors_to_ansi(fmt.aprintf("<debug-block> D </debug-block> <debug>{0}</debug>", text)))
	case .Warning: fmt.println(colors_to_ansi(fmt.aprintf("<warn-block> W </warn-block> <warn>{0}</warn>", text)))
	case .Error: fmt.println(colors_to_ansi(fmt.aprintf("<err-block> E </err-block> <err>{0}</err>", text)))
	case .Fatal: fmt.println(colors_to_ansi(fmt.aprintf("<fatal-block> F </fatal-block> <fatal>{0}</fatal>", text)))
	}
}

// log with context
logc :: proc(level:runtime.Logger_Level, ctx:string, text:string) {
	log.logf(level, "<context> {0} </context> {1}", ctx, text)
}

logcf :: proc(level:runtime.Logger_Level, ctx:string, text:string, args:..any) {
	log.logf(level, "{0}{1}",
		fmt.aprintf("<context> {0} </context> ", ctx),
		fmt.aprintf(text, ..args)
	)
}

// creates the logger
log_create_logger :: proc() -> log.Logger {
	logger:log.Logger
	logger.procedure = log_logging_proc
	return logger
}

log_init :: proc() {
	
	// connecting the vendor libraries to the global logging solution.
	raylib.SetTraceLogCallback(log_raylib_callback)
	log.logf(.Info, "Connected <vendor>{}</vendor> to logger", "raylib")
}

// callback function to connect raylib logging and intercept that into the global logging
// so we can output it correctly in the console, or save it to a file
log_raylib_callback :: proc "c" (msgType:raylib.TraceLogLevel, text:cstring, args: ^c.va_list) {
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
