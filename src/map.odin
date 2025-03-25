package map_example

import "core:fmt"

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

main :: proc() {
	basic()
	fmt.println("--------------")
	map_with_dynarr()
}

