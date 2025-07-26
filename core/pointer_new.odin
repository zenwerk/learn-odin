package pointer_example

import "core:fmt"

Foo :: struct {
	x: int,
}

Bar :: struct {
	x:   int,
	foo: ^Foo,
}

main :: proc() {
	num := new(f32)
	num^ = 42
	free(num)

	// 変数宣言と new では異なる
	foo: ^Foo
	fmt.println("foo:", foo) // <nil>
	foo2 := new(Foo)
	fmt.println("foo2:", foo2) // &Foo{x = 0}
	foo2^ = {
		x = 42,
	}
	fmt.println(foo2^) // Foo{x = 42}

	bar: ^Bar
	fmt.printfln("%v", bar) // <nil>
	bar2 := new(Bar)
	fmt.printfln("%v: %T", bar2, bar2) // &Bar{x = 0, foo = <nil>}: ^Bar
}

