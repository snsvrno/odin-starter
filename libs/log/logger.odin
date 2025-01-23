package snsvrno_log

import "base:runtime"
import "core:log"
import "core:fmt"

LOGGER:runtime.Logger

// custom logger function
logging_proc :: proc(data: rawptr, level: runtime.Logger_Level, text: string, options: bit_set[runtime.Logger_Option], location := #caller_location) {

	switch level {
	case .Info: out(colors_to_ansi(fmt.aprintf("<info-block> I </info-block> <info>{0}</info>", text)))
	case .Debug: out(colors_to_ansi(fmt.aprintf("<debug-block> D </debug-block> <debug>{0}</debug>", text)))
	case .Warning: out(colors_to_ansi(fmt.aprintf("<warn-block> W </warn-block> <warn>{0}</warn>", text)))
	case .Error: out(colors_to_ansi(fmt.aprintf("<err-block> E </err-block> <err>{0}</err>", text)))
	case .Fatal: out(colors_to_ansi(fmt.aprintf("<fatal-block> F </fatal-block> <fatal>{0}</fatal>", text)))
	}
}

create_logger :: proc() -> log.Logger {
	logger:log.Logger
	logger.procedure = logging_proc
	return logger
}

init :: proc() {
	when ODIN_OS == .Linux {
		raylib_connect()
	}
}

infof :: proc(template:string, params:..any) {
	log.infof(template, ..params)
}

logc :: proc(level:runtime.Logger_Level, ctx:string, text:string) {
	log.logf(level, "<context> {0} </context> {1}", ctx, text)
}

logcf :: proc(level:runtime.Logger_Level, ctx:string, text:string, args:..any) {
	log.logf(level, "{0}{1}",
		fmt.aprintf("<context> {0} </context> ", ctx),
		fmt.aprintf(text, ..args),
	)
}

