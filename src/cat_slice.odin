package slice_example

import "core:fmt"
import "core:math/rand"

Foo :: struct {
	x: int,
}

append_foo :: proc(foos: ^[dynamic]Foo) {
	random_age := rand.int_max(12) + 2
	append(foos, Foo{x = random_age})
}

print_foos :: proc(foos: []Foo) {
	for foo, i in foos {
		fmt.printfln("Foo[%d].x = %d", i, foo.x)
	}
}

mutate_foos :: proc(foos: []Foo) {
	// `&` 付与でスライスの要素を変更可能
	for &foo in foos {
		foo.x = rand.int_max(99)
	}
}

main :: proc() {
	foos: [dynamic]Foo
	append_foo(&foos)
	append_foo(&foos)

	print_foos(foos[:])
	mutate_foos(foos[:])
	print_foos(foos[:])
}

