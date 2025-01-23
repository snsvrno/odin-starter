package game

//import  shared "../shared"
import "libs:log"

data:^Data

APP_CONTEXT::"game"

@(export)
app_name:: proc() -> string {
	return "game"
}

@(export)
app_init :: proc() {
	log.logc(.Debug, APP_CONTEXT, "::init")

	app_init_data()
	app_load_data(data)

	init()
}

@(export)
app_exit :: proc() {
	log.logc(.Debug, APP_CONTEXT, "::exit")

}

@(export)
app_update :: proc(dt:f32) {
	update(dt)
}

@(export)
app_draw :: proc() {
	draw()
}

@(export)
app_init_data :: proc() {
	log.logc(.Debug, APP_CONTEXT, "::init_data")

	data = new(Data)
	data^ = data_init()
}

@(export)
app_load_data :: proc(existing_data:rawptr) {
	log.logc(.Debug, APP_CONTEXT, "::load_data")

	data = (^Data)(existing_data)
}

@(export)
app_get_data :: proc() -> rawptr {
	log.logc(.Debug, APP_CONTEXT, "::get_data")
	return data
}

@(export)
app_data_size :: proc() -> int {
	size := size_of(Data) 
	log.logcf(.Debug, APP_CONTEXT, "::data_size -> {}", size)
	return size
}
