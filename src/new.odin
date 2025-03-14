package exercise_dynamic_array

import "core:fmt"

main :: proc() {
	num := new(f32)
	num^ = 42
	free(num)

	Foo :: struct {
		x: int,
	}
	foo := new(Foo)
	foo^ = {
		x = 42,
	}
	fmt.println(foo^)

}

