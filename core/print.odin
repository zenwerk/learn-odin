package print_excircise

import "core:fmt"

MyStruct :: struct {
	x: int,
	y: bool,
}

// 型名を表示する方法
print_typeid_of_T :: proc($T: typeid) {
	// fmt.println を使って typeid の値を直接表示します。
	fmt.printf("渡された型 T の typeid は: %T\n", T{})
}

main :: proc() {
	print_typeid_of_T(int)    // int 型の typeid を渡す
	print_typeid_of_T(string) // string 型の typeid を渡す
	print_typeid_of_T(f32)    // f32 型の typeid を渡す
	print_typeid_of_T([9]int) // 固定配列 [9]int 型の typeid を渡す
	print_typeid_of_T(MyStruct)
}

