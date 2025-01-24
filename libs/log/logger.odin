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

/////////////////////////////////////////////////

info :: proc(params:..any) { log.info(..params) }
infof :: proc(template:string, params:..any) { log.infof(template, ..params) }
cinfo :: proc(ctx:string, value:any) { logc(.Info, ctx, value) }
cinfof :: proc(ctx:string, template:string, params:..any) { logcf(.Info, ctx, template, ..params) }

warn :: proc(params:..any) { log.warn(..params) }
warnf :: proc(template:string, params:..any) { log.warnf(template, ..params) }
cwarn :: proc(ctx:string, value:any) { logc(.Warning, ctx, value) }
cwarnf :: proc(ctx:string, template:string, params:..any) { logcf(.Warning, ctx, template, ..params) }

debug :: proc(params:..any) { log.debug(..params) }
debugf :: proc(template:string, params:..any) { log.debugf(template, ..params) }
cdebug :: proc(ctx:string, value:any) { logc(.Debug, ctx, value) }
cdebugf :: proc(ctx:string, template:string, params:..any) { logcf(.Debug, ctx, template, ..params) }

error :: proc(params:..any) { log.error(..params) }
errorf :: proc(template:string, params:..any) { log.errorf(template, ..params) }
cerror :: proc(ctx:string, value:any) { logc(.Error, ctx, value) }
cerrorf :: proc(ctx:string, template:string, params:..any) { logcf(.Error, ctx, template, ..params) }

fatal :: proc(params:..any) { log.fatal(..params) }
fatalf :: proc(template:string, params:..any) { log.fatalf(template, ..params) }
cfatal :: proc(ctx:string, value:any) { logc(.Fatal, ctx, value) }
cfatalf :: proc(ctx:string, template:string, params:..any) { logcf(.Fatal, ctx, template, ..params) }

log :: proc(level:runtime.Logger_Level, params:..any) { log.log(level, ..params) }
logf :: proc(level:runtime.Logger_Level, template:string, params:..any) { log.logf(level, template, ..params) }

logc :: proc(level:runtime.Logger_Level, ctx:string, value:any) {
	log.logf(level, "<context> {0} </context> {1}", ctx, value)
}

logcf :: proc(level:runtime.Logger_Level, ctx:string, text:string, args:..any) {
	log.logf(level, "{0}{1}",
		fmt.aprintf("<context> {0} </context> ", ctx),
		fmt.aprintf(text, ..args),
	)
}

