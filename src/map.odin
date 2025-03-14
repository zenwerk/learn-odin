package map_example

import "core:fmt"

main :: proc() {
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

