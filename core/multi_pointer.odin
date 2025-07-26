package multi_pointer_example

import "core:fmt"

Foo :: struct {
	value: int,
}

main :: proc() {
	// Foo の固定長配列を作成
	foos := [3]Foo{{value = 1}, {value = 2}, {value = 3}}

	// 配列の最初の要素へのポインターを取得
	ptr := &foos

	// ptr を Foo のマルチポインターにキャスト
	multi_ptr := ([^]Foo)(ptr)

	// ポインターの型を表示
	fmt.printfln("ptr: %T, multi_ptr: %T", ptr, multi_ptr)

	// マルチポインターを使用して配列の要素にアクセス
	fmt.println(ptr)                // -> &[Foo{value = 1}, Foo{value = 2}, Foo{value = 3}] 固定配列へのアドレス
	fmt.println(multi_ptr)          // -> &Foo{value = 1} 構造体のアドレス

	fmt.println(multi_ptr[0])       // -> Foo{value = 1}
	fmt.println(multi_ptr[0].value) // -> 1
	fmt.println(multi_ptr[1].value) // -> 2
	fmt.println(multi_ptr[2].value) // -> 3

	// Out of renge / Segmentation fault にはならずゼロ値が表示される
	fmt.println(multi_ptr[3])

	// raw_data を使用してスライスのマルチポインターを取得する例 [5]
	slice := []Foo{{10}, {20}}
	multi_ptr_slice := raw_data(slice)
	fmt.println(multi_ptr_slice[0].value) // -> 10
	fmt.println(multi_ptr_slice[1].value) // -> 20
	fmt.println(multi_ptr_slice[2].value) // -> 実行時ごとに不定の値
}
