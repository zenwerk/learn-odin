package iter_example

import "core:fmt"


Foo :: struct {
	x:    int,
	used: bool,
}

// イテレーションの状態を保存する構造体
Foo_Iterator :: struct {
	index: int,
	data:  []Foo,
}

// イテレータの作成
make_foo_iterator :: proc(data: []Foo) -> Foo_Iterator {
	return {data = data}
}

// イテレーションの実行
foo_iterator :: proc(it: ^Foo_Iterator) -> (val: Foo, idx: int, cond: bool) {
	cond = it.index < len(it.data)

	for ; cond; cond = it.index < len(it.data) {
		// used が false の場合はスキップしループに現れない
		if !it.data[it.index].used {
			it.index += 1
			continue
		}

		val = it.data[it.index]
		idx = it.index
		it.index += 1
		break
	}

	return
}

main :: proc() {
	// 128 個の Foo を用意する
	foos := make([]Foo, 128)
	foos[10] = {
		x    = 7,
		used = true,
	}

	// used ==  true の場合のみ現れるイテレータ
	it := make_foo_iterator(foos[:])
	for val in foo_iterator(&it) {
		fmt.println(val) // foos[10] のみ出力される
	}
}

