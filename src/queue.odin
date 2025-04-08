package queue_excircise

import "core:container/queue"
import "core:fmt"

main :: proc() {
	// 整数のキューを作成し、初期容量を5に設定
	q: queue.Queue(int)
	queue.init(&q, capacity = 5)
	defer queue.destroy(&q) // プログラム終了時にキューを破棄

	fmt.println("初期のキューの長さ:", queue.len(q))
	fmt.println("初期のキューの容量:", queue.cap(q))

	// 後ろに要素を追加
	ok, err := queue.push_back(&q, 10)
	if ok {
		fmt.println("後ろに 10 を追加しました")
	}
	queue.push_back(&q, 20)
	queue.push_back(&q, 30)

	// 前に要素を追加
	ok, err = queue.push_front(&q, 5)
	if ok {
		fmt.println("前に 5 を追加しました")
	}

	fmt.println("要素を追加後のキューの長さ:", queue.len(q))

	// 先頭の要素を取得
	if queue.len(q) > 0 {
		先頭の要素 := queue.front(&q)
		fmt.println("先頭の要素:", 先頭の要素)
	}

	// 末尾の要素を取得
	if queue.len(q) > 0 {
		末尾の要素 := queue.back(&q)
		fmt.println("末尾の要素:", 末尾の要素)
	}

	// 後ろから要素を取り出す
	if queue.len(q) > 0 {
		要素 := queue.pop_back(&q)
		fmt.println("後ろから取り出した要素:", 要素)
	}

	// 前から要素を取り出す
	if queue.len(q) > 0 {
		要素 := queue.pop_front(&q)
		fmt.println("前から取り出した要素:", 要素)
	}

	fmt.println("要素を取り出し後のキューの長さ:", queue.len(q))

	// キューをクリア
	queue.clear(&q)
	fmt.println("クリア後のキューの長さ:", queue.len(q))
}

