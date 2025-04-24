package main

import "core:fmt"

Stack :: struct($T: typeid) {
	data: [dynamic]T,
}

stack_new :: proc($T: typeid) -> ^Stack(T) {
	s := new(Stack(T))
	s.data = make([dynamic]T)
	return s
}

stack_free :: proc(stack: ^Stack($T)) {
	// スタックのメモリを解放
	delete(stack.data)
	free(stack)
}

stack_pop :: proc(stack: ^Stack($T)) -> T {
	// 配列が空の場合はエラーを出す
	assert(len(stack.data) > 0, "Stack underflow")
	value := stack.data[len(stack.data) - 1]
	ordered_remove(&stack.data, len(stack.data) - 1)
	return value
}

stack_peek :: proc(stack: ^Stack($T)) -> T {
	// 配列が空の場合はエラーを出す
	assert(len(stack.data) > 0, "Stack is empty")
	return stack.data[len(stack.data) - 1]
}

stack_push :: proc(stack: ^Stack($T), value: T) {
	// 動的配列に値を追加
	append(&stack.data, value)
}

stack_dump :: proc(stack: ^Stack($T)) {
	// スタックの内容を表示
	fmt.println("Stack contents:", stack.data)
}

main :: proc() {
	// 整数型のスタックを作成
	stack := stack_new(int)
	defer delete(stack.data)
	defer free(stack)

	stack_push(stack, 10)
	stack_push(stack, 20)
	stack_push(stack, 30)

	stack_dump(stack) // Stack contents: [10, 20, 30]

	fmt.println("Peek:", stack_peek(stack)) // Peek: 30

	fmt.println("Pop:", stack_pop(stack)) // Pop: 30
	stack_dump(stack) // Stack contents: [10, 20]
}