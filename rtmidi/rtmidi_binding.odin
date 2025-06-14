package rtmidi_binding

import "core:fmt"
import rtmidi "../rtmidi/odin-rtmidi"

main :: proc() {
    fmt.println("Hello, world!")
    v := rtmidi.rtmidi_get_version()
    fmt.println(string(v))
    fmt.println(string(rtmidi.rtmidi_api_display_name(.MACOSX_CORE)))
    fmt.println(string(rtmidi.rtmidi_api_name(.MACOSX_CORE)))
}
