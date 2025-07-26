package slice_literal_pitfall

import "core:fmt"

numbers: []int

set_numbers :: proc() {
	_numbers := [3]int{7, 42, 13}
	numbers = _numbers[:]
	fmt.println(numbers)
}

main :: proc() {
	set_numbers()
	fmt.println(numbers)
}

