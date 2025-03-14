package string_example

import "core:fmt"
import "core:unicode/utf8"


main :: proc() {
    // rune to string
    r := 'A'
    s := utf8.runes_to_string([]rune{r})

    fmt.println(r, s)

    words := []string{"Hello", "world", "from", "Odin"}
    joined := join(words, " ")
    fmt.println(joined) // 出力: "Hello world from Odin"
}
