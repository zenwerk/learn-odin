package map_example

import "core:fmt"
import "core:slice"

basic :: proc() {
	m: map[string]int // 宣言
	m["foo"] = 1
	m["bar"] = 2
	m["baz"] = 3

	// 要素の削除
	delete_key(&m, "foo")

	// 要素の取得
	if v, ok := m["bar"]; ok {
		fmt.println(v)
	}

	// 実行時エラーにはならない
	does_not_exist := m["foo"]
	fmt.println(does_not_exist) // 0

	// in, not_in
	fmt.println("bar" in m) // true
	fmt.println("foo" not_in m) // true

	// delete しないとメモリリーク
	delete(m)
}

map_with_dynarr :: proc() {
	m := make(map[string][dynamic]int)

	// ゼロ値のとき、これは意味がないようだ
	append(&m["a"], 1)
	fmt.printfln("m[a] = %v", m["a"]) // m[a] = []

	a, ok := m["a"]
	fmt.printfln("%v:%T, %v", a, a, ok) // []:[dynamic]int, false
	m["a"] = a

	// 初期化は反映される
	append(&m["a"], 1)
	fmt.printfln("m[a] = %v", m["a"]) // m[a] = [1]
}


map_with_dynarr_2 :: proc() {
	m := make(map[int][dynamic]int)
	defer delete(m)

	dynarr := make([dynamic]int)
	append(&dynarr, 1, 2, 3)
	safe_array := slice.clone_to_dynamic(dynarr[:])
	defer delete(safe_array)

	m[0] = dynarr
	fmt.println("map:", m) // map[0=[1, 2, 3]]

	// dynarr を delete すると、マップの要素は無効になる
	delete(dynarr)
	fmt.println("dynarr (after delete):", dynarr) // 内部的には無効なポインタになっている可能性あり
	fmt.println("map[0] (dynarr):", m[0]) // 不定の値が表示される

	// ディープコピーしたものは影響を受けない
	m[1] = safe_array
	fmt.println("map[1] (safe copy):", m[1]) // [1, 2, 3]
}

main :: proc() {
	basic()
	fmt.println("--------------")
	map_with_dynarr()
	fmt.println("--------------")
	map_with_dynarr_2()
}

