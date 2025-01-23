package main

import game "../../src"
import shared "../../shared"

import "vendor:raylib"
import "core:fmt"
import "libs:log"

main :: proc() {
 // connecting the logger
	context.logger = log.create_logger()
	log.LOGGER = context.logger
	log.init()
	log.infof("starting <game_name>{0}</game_name> (<game_version>{1}</game_version> built from <build_artifact>{2}</build_artifact> at <build_time>{3}</build_time>)",
		shared.GAME_NAME, shared.GAME_VERSION, shared.BUILD_ARTIFACT, shared.BUILD_TIME)

	window_title := fmt.caprintf("{0} ({1})", shared.GAME_NAME, shared.GAME_VERSION)
	raylib.InitWindow(shared.WINDOW_X, shared.WINDOW_Y, window_title)
	raylib.SetExitKey(raylib.KeyboardKey.ESCAPE)
	raylib.SetTargetFPS(120)

	game.app_init()
	for !raylib.WindowShouldClose() {
		dt := f32(raylib.GetFrameTime())
		game.app_update(dt)

		raylib.BeginDrawing()
			game.app_draw()
		raylib.EndDrawing()
	}

	game.app_exit()
	raylib.CloseWindow()
}
