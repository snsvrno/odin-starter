package main

import "base:runtime"
import "core:c"
import "vendor:raylib"
import "core:mem"
import "core:fmt"

import "libs:log"
import game "../../src"
import shared "../../shared"

@(private="file")
web_context:runtime.Context

@(private="file")
@thread_local temp_allocator:Default_Temp_Allocator

@export
web_init :: proc "c" () {
	context = runtime.default_context()
	context.allocator = emscripten_allocator()
	default_temp_allocator_init(&temp_allocator, 1*mem.Megabyte)
	context.temp_allocator = default_temp_allocator(&temp_allocator)
	context.logger = log.create_logger()
	log.init()
	web_context = context

	log.infof("starting <game_name>{0}</game_name> (<game_version>{1}</game_version> built from <build_artifact>{2}</build_artifact> at <build_time>{3}</build_time>)",
		shared.GAME_NAME, shared.GAME_VERSION, shared.BUILD_ARTIFACT, shared.BUILD_TIME)
	window_title := fmt.caprintf("{0} ({1})", shared.GAME_NAME, shared.GAME_VERSION)
	raylib.SetConfigFlags({ .WINDOW_RESIZABLE })
	raylib.InitWindow(256, 256, window_title)

	game.app_init()
}

@export
web_update :: proc "c" () {
	context = web_context

	dt := f32(raylib.GetFrameTime())
	game.app_update(dt)
	
	raylib.BeginDrawing()
		game.app_draw()
	raylib.EndDrawing()
}

@export
web_window_size_changed :: proc "c" (w: c.int, h: c.int) {
	context = web_context
	game.resize(int(w), int(h))
}
