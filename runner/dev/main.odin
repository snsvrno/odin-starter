package main

import "core:log"
import "core:os"
import "core:time"
import "core:fmt"

import "vendor:raylib"

import shared "../../shared"

BACKGROUND_COLOR:raylib.Color={ 15, 15, 15, 255 }

loaded_apps:[]App
active_app:^App
canvas:raylib.RenderTexture2D

main :: proc() {
	context.logger = shared.log_create_logger()
	shared.LOGGER = context.logger
	init()

	// load all apps
	loaded_apps = app_load_all() or_else os.exit(1)
	// pick which one to run first
	for i in 0 ..< len(loaded_apps) {
		if (loaded_apps[i].name() == "game") {
			log.logf(.Debug, "setting starting app to <title>{}</title>", "game")
			load_app(&loaded_apps[i])
			break
		}
	}
	menu_generate()
	// checking that we loaded something
	if active_app == nil {
		log.log(.Fatal, "no app loaded")
		os.exit(1)
	}

	for !raylib.WindowShouldClose() {

		key_pressed()
		mouse_pressed()

		hotreload()

		if raylib.IsWindowResized() do resize(int(raylib.GetScreenWidth()), int(raylib.GetScreenHeight()))

		update()
		draw()
	}

	exit()
}

mouse_pressed :: proc() {
	if raylib.IsMouseButtonDown(.LEFT) {
		menu_mouse_pressed()
	}
}

key_pressed :: proc() {
	key := raylib.GetKeyPressed()
	for key != .KEY_NULL {
		menu_key_pressed(key)
		key = raylib.GetKeyPressed()
	}
}

app_reload_timer := time.tick_now()
// will check all the things that we care about and reload
// what has changed
hotreload :: proc() {
	if time.tick_since(app_reload_timer) > APP_RELOAD {
		app_reload_timer = time.tick_now()

		// checks all the loaded apps
		for i in 0 ..< len(loaded_apps) {
			if app_has_changed(&loaded_apps[i]) {
				if app_reload(&loaded_apps[i]) or_continue {
					loaded_apps[i].loaded = false
					// will reload the app if we hot-reloaded the active
					// app, the other ones should be handled when switching
					// between active apps
					if loaded_apps[i].name() == active_app.name() {
						load_app(active_app)
					}
				}
			}
		}

	}
}

init :: proc() {
	shared.log_init()
	log.logf(.Info, "starting <game_name>{0}</game_name> (<game_version>{1}</game_version> built from <build_artifact>{2}</build_artifact> at <build_time>{3}</build_time>))",
		shared.GAME_NAME, shared.GAME_VERSION, shared.BUILD_ARTIFACT, shared.BUILD_TIME)

	window_handle := raylib.GetWindowHandle()
	if window_handle == nil {
		log.log(.Debug, "no window, creating new window")
		window_title := fmt.caprintf("{0} ({1})", shared.GAME_NAME, shared.GAME_VERSION)
		raylib.InitWindow(shared.WINDOW_X, shared.WINDOW_Y, window_title)
		raylib.SetExitKey(raylib.KeyboardKey.ESCAPE)

		raylib.SetTargetFPS(120)
	}

	// initalize the canvas
	resize(shared.WINDOW_X, shared.WINDOW_Y)
}

resize :: proc(w:int, h:int) {
	log.logf(.Info, "::resize {}, {}", w, h)
	raylib.UnloadRenderTexture(canvas)
	canvas = raylib.LoadRenderTexture(i32(w), i32(h-MENU_HEIGHT))
}

exit :: proc() {
	log.log(.Info, "exiting")
	app_cleanup_versions(loaded_apps)
	raylib.CloseWindow()
}

update :: proc() {
	dt := f32(raylib.GetFrameTime())
	active_app.update(dt)
}

draw :: proc() {
	raylib.BeginDrawing()

		raylib.ClearBackground(BACKGROUND_COLOR)
		raylib.BeginTextureMode(canvas)
			active_app.draw()
		raylib.EndTextureMode()
		raylib.DrawTexture(canvas.texture, 0, i32(MENU_HEIGHT), raylib.WHITE)

		draw_menu()

	raylib.EndDrawing()
}

// sets the app as the main running app
load_app :: proc(app:^App) {

	// if this is the same app then we want to reload the app
	if app == active_app {
		log.logf(.Info, "reloading app <title>{}</title>", active_app.name())
		free(active_app.get_data())
		active_app.loaded = false
	} else {
		active_app = app
	}

	if !active_app.loaded {
		active_app.init()
	}
}
