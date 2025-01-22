package main

import "core:dynlib"
import "core:log"
import "core:time"
import "core:os"
import "core:fmt"
import "core:path/filepath"

import shared "../../shared"

APP_CTX::"runner/app-loader"
APP_RELOAD::time.Duration(1_000_000_000)
APP_ROOT:=filepath.join([]string{ os.get_current_directory(), filepath.dir(os.args[0]) })

App :: struct {
	init:proc(),
	exit:proc(),

	draw:proc(),
	update:proc(dt:f32),

	get_data:proc() -> rawptr,
	load_data:proc(data:rawptr),
	data_size:proc() -> int,

	// interfacing things
	name:proc() -> string,

	// management things
	loaded:bool,
	source_path:string,
	version:int,
	timestamp:os.File_Time
}

// will scan the game directory and find and load any valid
// apps
app_load_all :: proc() -> (apps:[]App, ok:bool) {
	working:[dynamic]App

	handle, err := os.open(APP_ROOT)
	if err != os.ERROR_NONE {
		log.logf(.Warning, "error opening root app directory <path>{}</path>: {}", APP_ROOT, err)
		return
	}

	files, read_err := os.read_dir(handle, 0)
	if read_err != os.ERROR_NONE {
		log.logf(.Warning, "error reading root app directory <path>{}</path>: {}", APP_ROOT, err)
		return
	}

	for file in files {
		if filepath.ext(file.fullpath) == ".so" {

			// first copy
			working_path, copy_ok := app_copy(file.fullpath, 0)
			if !copy_ok { shared.logcf(.Warning, APP_CTX, "skipping {}", file.name); continue } 

			app:App
			if symbols, ok := dynlib.initialize_symbols(&app, working_path, "app_"); ok {

				// check that we didn't load something with the same name
				for a in working {
					if a.name() == app.name() {
						shared.logcf(.Fatal, APP_CTX, "two apps have the same name - {}: <title>(1)</title> {} and <title>(2)</title> {}",
							a.name(), filepath.base(a.source_path), file.name)
					}
				}

				timestamp, time_err := os.last_write_time_by_name(file.fullpath)
				if time_err != os.ERROR_NONE {
					shared.logcf(.Warning, APP_CTX, "unable to get library time: error code <number>{0}</number>", time_err)
					shared.logcf(.Warning, APP_CTX, "skipping loading {}", file.name)
					continue
				}

				shared.logcf(.Debug, APP_CTX, "loaded library <title>{}.0</title>", file.name)

				app.version = 1
				app.source_path = file.fullpath
				app.timestamp = timestamp
				append(&working, app)
			}
		}
	}

	return working[:], true
}

// used to copy the library to a temp one so that we can load it
// and now bother the os with locking / holding it.
//
// this make it easier to recompile the libraries and hot reload
// them
app_copy :: proc(path:string, ver:int) -> (new_path:string, ok:bool) {

	new_path = filepath.join( []string {
		filepath.dir(path),
		fmt.aprintf("{}.{}", filepath.base(path), ver)
	})

	if data, read_ok := os.read_entire_file_from_filename(path); read_ok {
		if len(data) == 0 { shared.logc(.Error, APP_CTX, "app has 0 size?"); return; }
		if !os.write_entire_file(new_path, data) { 
			shared.logcf(.Error, APP_CTX, "failed to copy library to <path>{0}</path>", filepath.base(new_path))
			return
		}
	} else { shared.logc(.Error, APP_CTX, "could not read the library"); return }

	return new_path, true
}

// removes all the copied versions that are made when loading apps
// these are made with `app_copy`
app_cleanup_versions :: proc(apps:[]App) {
	for app in apps {
		shared.logcf(.Debug, APP_CTX, "cleaning up library versions of <title>{}</title>", filepath.base(app.source_path))
		for i := 0; i <= app.version; i += 1 {
			new_library_path := fmt.aprintf("{0}.{1}", app.source_path, i)
			if os.exists(new_library_path) do os.remove(new_library_path)
		}
	}
}

// will check if the os time stamp on the file has changed
app_has_changed :: proc(app:^App) -> bool {
	timestamp, time_err := os.last_write_time_by_name(app.source_path)
	if time_err != os.ERROR_NONE {
		shared.logcf(.Warning, APP_CTX, "unable to get library time: error code <number>{0}</number>", time_err)
		return false
	}
	if (timestamp == app.timestamp) { return false }
	else do return true
}

// will reload the library procs from the disk into the app struct
app_reload :: proc(app:^App) -> (needs_reload:bool, ok:bool) {

	new_path  := app_copy(app.source_path, app.version) or_return
	app.version += 1

	old_data := app.get_data()
	old_data_size := app.data_size()

	if symbols, init_ok := dynlib.initialize_symbols(app, new_path, "app_"); !init_ok { 
		shared.logcf(.Error, APP_CTX, "failed to reload {}", filepath.base(new_path)); 
		return 
	}

	shared.logcf(.Debug, APP_CTX, "loaded library <title>{}</title>", filepath.base(new_path))

	reload:=false
	if old_data_size != app.data_size() {
		shared.logc(.Debug, APP_CTX, "data has changed size, will need a reload")
		reload = true
		free(old_data)
	} else {
		app.load_data(old_data)
	}

	if timestamp, time_err := os.last_write_time_by_name(app.source_path); time_err != os.ERROR_NONE {
		shared.logcf(.Warning, APP_CTX, "unable to get library time: error code <number>{0}</number>", time_err)
		shared.logcf(.Warning, APP_CTX, "skipping loading {}", filepath.base(new_path))
		return
	} else do app.timestamp = timestamp


	return reload, true
}
