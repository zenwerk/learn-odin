package exercise_dynamic_array

import "core:fmt"

main :: proc() {
	my_ints: [dynamic]int

	for i in 0 ..< 1024 {
		print_info(my_ints)
		append(&my_ints, 5)
	}
}

print_info :: proc(arr: [dynamic]int) {
	fmt.printfln("len: %v", len(arr))
	fmt.printfln("cap: %v", cap(arr))
	fmt.printfln("data: %p", raw_data(arr))
}

