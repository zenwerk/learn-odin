package minimal_example

import sapp "./sokol-odin/sokol/app"
import "base:runtime"

init :: proc "c" () {
	context = runtime.default_context()
}

frame :: proc "c" () {
	context = runtime.default_context()
}

cleanup :: proc "c" () {
	context = runtime.default_context()
}

main :: proc() {
	sapp.run({
		init_cb = init,
		frame_cb = frame,
		cleanup_cb = cleanup,
		width = 640,
		height = 480,
		window_title = "空のウィンドウ",
	})
}