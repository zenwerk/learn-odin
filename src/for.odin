package for_example

import "core:fmt"

main :: proc() {
    i := 0
    for {
        i += 1
        if i > 10 {
            break
        }
    }
    fmt.println("exit")
}

