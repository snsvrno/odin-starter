package main

import "core:fmt"
import "core:strings"
import "core:log"

import "vendor:raylib"

MENU_PADDING::8
MENU_FONT_SIZE::32
MENU_BOTTOM_LINE::8
MENU_HEIGHT:=MENU_FONT_SIZE + MENU_PADDING * 2 + MENU_BOTTOM_LINE

MENU_COLOR_ACTIVE:raylib.Color = { 55, 75, 200, 255 }
MENU_COLOR_OVER:raylib.Color = { 255, 0, 0, 255 }

MenuItem :: struct {
	x:i32, y:i32, w:i32, h:i32,
	text:cstring, over:bool
}

menu_def:[]MenuItem

menu_generate :: proc() {
	working:[dynamic]MenuItem
	for i in 0 ..< len(loaded_apps) {
		text := fmt.caprintf("{} [F{}]", strings.to_upper(loaded_apps[i].name()), i + 1)
		text_width := raylib.MeasureText(text, MENU_FONT_SIZE)
		append(&working, MenuItem {
			x = 0, y = 0,
			w = text_width + MENU_PADDING * 2, 
			h = MENU_FONT_SIZE + MENU_PADDING * 2,
			text = text
		})
	}
	menu_def = working[:]
}

draw_menu :: proc() {
	for i in 0 ..< len(menu_def) {
		text_color:=MENU_COLOR_ACTIVE

		if &loaded_apps[i] == active_app || menu_def[i].over {
			bg_color:=MENU_COLOR_ACTIVE
			if menu_def[i].over do bg_color = MENU_COLOR_OVER

			raylib.DrawRectangle(
				menu_def[i].x, menu_def[i].y,
				menu_def[i].w, menu_def[i].h,
				bg_color
			)
			text_color = BACKGROUND_COLOR
		}

		raylib.DrawText(menu_def[i].text,
			menu_def[i].x + MENU_PADDING, menu_def[i].y + MENU_PADDING,
			MENU_FONT_SIZE, text_color
		)

	}

	raylib.DrawRectangle(
		0, i32(MENU_HEIGHT - MENU_BOTTOM_LINE),
		raylib.GetScreenWidth(), MENU_BOTTOM_LINE,
		MENU_COLOR_ACTIVE
	)
}

// switches the active app if pressing the menu item
menu_mouse_pressed :: proc() {
	x:=raylib.GetMouseX()
	y:=raylib.GetMouseY()

	for i in 0 ..< len(menu_def) {
		if menu_def[i].x <= x && x <= menu_def[i].w + menu_def[i].x &&
			menu_def[i].y <= y && y <= menu_def[i].h + menu_def[i].y {
			load_app(&loaded_apps[i])
		}
	}
}

// checks if key F1 to F8 is pressed and will reload that respective
// app, or switch it
menu_key_pressed :: proc(key:raylib.KeyboardKey) {
		if key >= raylib.KeyboardKey.F1 && key <= raylib.KeyboardKey.F8 {
			number := int(key) - 290
			load_app(&loaded_apps[number])
		}
}
