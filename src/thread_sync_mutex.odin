//
// Demonstrates how to spawn multiple threads and safely access data 
// from each by using a mutex.
// 複数のスレッドを起動し、ミューテックスを使ってそれぞれのスレッドから安全にデータにアクセスする方法を示す。
//
package thread_sync_example

import "core:fmt"
import "core:math/rand"
import "core:sync"
import "core:thread"
import "core:time"

// Defines an arbitrary work item. To simulate the CPU work on
// these items, each will have a "processing time" that each thread will
// wait for before continuing onto the next item.
// 任意の作業項目を定義する。これらの項目のCPU作業をシミュレートするために、各スレッドは次の項目に進む前に待つ「処理時間」を持つ。
Work_Item :: struct {
	item_tag:        i32,
	processing_time: f32, // 処理時間
}

create_randomized_queue :: proc(num_items: int) -> (q: [dynamic]Work_Item) {
	// This initializes the queue with a length of zero, and a capacity of `num_items`.
	// Pre-allocating space when you know how much you need is good!
	// これはキューの長さを 0、容量を `num_items` として初期化します。必要な容量がわかっているときにあらかじめ領域を確保しておくのは良いことです！
	q = make([dynamic]Work_Item, 0, num_items)

	// Initialize the items in the queue. Each item will have a unique tag,
	// and a random "processing time".
	// キュー内のアイテムを初期化する。各アイテムはユニークなタグを持ち、ランダムな「処理時間」を持つ。
	for i in 0 ..< num_items {
		item: Work_Item
		item.item_tag = i32(i) + 1
		// This sets the item's processing time to a value between 0.1 and 0.51 (exclusive).
		// これは、アイテムの処理時間を0.1から0.51（排他的）の間の値に設定します。
		item.processing_time = rand.float32_range(0.1, 0.51)
		append(&q, item)
	}

	return
}

// This is the procedure that we'll be running in the threads that we spawn later.
// このプロシージャーは、この後スポーンするスレッドで実行される。
process_item :: proc(queue: ^[dynamic]Work_Item, mutex: ^sync.Mutex, thread_identifier: int) {
	// This proc is essentially an infinite loop that breaks once it no longer has any data to process.
	// このプロックは基本的に無限ループで、処理するデータがなくなるとループを抜ける。

	for {
		// First we need to get a lock on our mutex. 
		// That way we know whether we can safely access our queue, or whether 
		// another thread is using it already.
		// まず、ミューテックスをロックする必要がある。そうすることで、キューに安全にアクセスできるのか、それとも他のスレッドがすでにキューを使っているのかを知ることができる。
		sync.mutex_lock(mutex)

		// This is the critical point where the mutex being locked matters.
		// Here we attempt to pop the first element off of our queue.
		// これは、ミューテックスがロックされていることが重要なポイントである。ここでは、キューから最初の要素を取り出そうとしている。
		item, pop_ok := pop_front_safe(queue)

		// Now that we've got the data we need from the queue, we can unlock our mutex 
		// to let other threads access the queue to perform their work.
		// これでキューから必要なデータを取得できたので、他のスレッドがキューにアクセスして作業を行えるように、ミューテックスのロックを解除することができる。
		sync.mutex_unlock(mutex)

		// If we tried to pop something off but the queue was empty, we have nothing left to
		// process, so we'll just break out of our ininite loop.
		// Once the loop ends, our function will return, and the thread will stop.
		// もし何かを弾き出そうとしてもキューが空だったら、処理するものは何も残っていないので、無限ループから抜け出すだけだ。ループが終了すれば、関数が戻り、スレッドは停止する。
		if !pop_ok {
			break
		}

		// Now we can do our item processing! Which in this case is just "processing" it for 
		// the item's `processing_time` in seconds.
		//
		// Since `processing_time` is a f32, you need to cast `time.Second` to a f32, 
		// then back to `time.Duration` to get your fraction of a second.
		//
		// これでアイテムの処理を行うことができます！
		// この場合、アイテムの `processing_time` を秒単位で "処理" することになります。
		// processing_time`はf32なので、`time.Second`をf32にキャストし、`time.Duration`に戻って秒の端数を取得する必要があります。
		time.sleep(time.Duration(f32(time.Second) * item.processing_time))

		// After we've done our "processing" (sleeping on the job, really), we can print
		// some info to the console about our item, and the thread that grabbed it.
		// 処理」を終えたら（本当は寝ているのだが）、コンソールにアイテムとそれをつかんだスレッドに関する情報を表示することができる。
		//
		// `fmt.printfln` and the other `fmt` procs that print to stdout are thread-safe, 
		// so nothing to worry about here.
		// fmt.printfln`と、標準出力にプリントする他の`fmt`関数はスレッドセーフなので、ここで心配することはない。
		fmt.printfln(
			"[THREAD %02d] Item %04d processed in %0.2f seconds.",
			thread_identifier,
			item.item_tag,
			item.processing_time,
		)
	}
}

main :: proc() {
	// This `RANDOM_SEED` is just a compile-time constant that will
	// seed the default random generator if specified as a non-zero value.
	// I added this in to allow for predictable, reproducible outputs.
	// この `RANDOM_SEED` は単なるコンパイル時の定数で、ゼロ以外の値として指定された場合、デフォルトのランダムジェネレーターの種となる。これを追加したのは、予測可能で再現性のある出力を可能にするためだ。
	//
	// When it's 0, Odin's random generator is seeded as it normally would be by default.
	// Otherwise, this `when` clause kicks in at compile-time
	// and will override the default seeding mechanism.
	// これが0の場合、Odinのランダムジェネレータはデフォルトのシードが行われます。そうでない場合、この `when` 節はコンパイル時に有効になり、デフォルトのシード機構を上書きします。
	//
	// To specify it yourself, you can just add `--define:RANDOM_SEED=...`
	// to your `odin build/run` command.
	// 自分で指定するには、`--define:RANDOM_SEED=...` を `odin buil/drun` コマンドに追加すればよい。
	RANDOM_SEED: u64 : #config(RANDOM_SEED, 0)
	when RANDOM_SEED > 0 {
		state := rand.create(RANDOM_SEED)
		context.random_generator = rand.default_random_generator(&state)
	}

	// Initialize a randomized set of data to work off of.
	// It'll be a dynamic array of `Work_Items`, which essentially just have an ID number and a duration.
	// ランダムなデータセットを初期化する。これは`Work_Items`の動的配列で、基本的にはID番号と期間を持つだけである。
	queue := create_randomized_queue(500)

	// This is a Mutex. (Short for "mutual exclusion lock")
	// It doesn't actually hold any data, but rather it's used in multi-threaded 
	// applications as a way to tell other threads when it's safe to access data.
	// これがミューテックスだ。("相互排他ロック "の略）実際にはデータを保持しないが、マルチスレッドでは、データにアクセスしても安全なタイミングを他のスレッドに伝える手段として使われる。
	//
	// A Mutex starts in an UNLOCKED state. At any time, you can LOCK a Mutex using `sync.lock`.
	// If a Mutex is LOCKED, that means when something else tries to LOCK it, it will halt the 
	// execution of that thread since another thread has already LOCKED it.
	// ミューテックスは UNLOCKED 状態から始まる。いつでも `sync.lock` を使ってミューテックスを LOCK することができる。ミューテックスが LOCKED の場合、他のスレッドがそれを LOCK しようとすると、他のスレッドが既にそれを LOCK しているため、そのスレッドの実行が停止します。
	//
	// However, once the Mutex is UNLOCKED, any thread can LOCK it for themselves.
	// しかし、いったんミューテックスがUNLOCKされると、どのスレッドも自分自身のためにそれをLOCKすることができる。
	//
	// Mutexes can be used to guarantee safe access to data across multiple threads. Once a thread locks it, 
	// any other threads that also try to lock it will be forced to wait. 
	// This prevents two threads from reading/writing the same data, which can result in data races.
	// ミューテックスは、複数のスレッドにまたがるデータへの安全なアクセスを保証するために使うことができる。
	// あるスレッドがデータをロックすると、他のスレッドもロックしようとする場合は強制的に待たされる。これにより、2つのスレッドが同じデータを読み込むことができなくなり、データ・レースが発生する可能性がある。
	mutex: sync.Mutex


	// This constant int is going to define how many threads we actually want to run.
	MAX_THREADS: int : 8
	// And here we define an array that's going to hold all of the Threads that we spawn.
	threads: [MAX_THREADS]^thread.Thread

	// Let's start making some threads.
	for i in 0 ..< len(threads) {
		// Let's get which thread number this is so we can pass it to our threaded proc.
		// どのスレッド番号なのか、それをスレッド・プロックに渡せるようにしよう。
		t_id := i + 1
		// This is where the magic happens. We're going to create up to our MAX number of Threads and store them in our 
		// `threads` array.
		// Since our thread proc takes three arguments, we need a way to pass these in.
		// Luckily, `create_and_start_with_poly_data` exists! It allows you to pass in function arguments that get 
		// consumed by the thread proc easily.
		// ここでマジックが起こる。スレッドを最大数まで作成し、それを `threads` 配列に格納する。スレッド proc は3つの引数を取るので、これらを渡す方法が必要だ。
		// 幸運なことに `create_and_start_with_poly_data` が存在する！これを使うと、スレッド proc が消費する関数の引数を簡単に渡すことができる。
		//
		// Now to explain exactly what these arguments are:
		//      &queue  - A pointer to our queue object. We need to pass it by pointer to pop items off of it!
		//      &mutex  - A pointer to our mutex. This is what our threads will use to signal to each other that they 
		//				need exclusive access to the queue at the critical point where they access it.
		//      t_id    - Just the index of our thread + 1, for printing purposes so we can identify who's working.
		//
		//      process_item - This is our procedure! The thread is going to make this thing run with all of the 
		//		previous arguments passed into it.
		//
		// With all that out of the way, let's create our thread and store it in `threads` at index `i` for later!
		threads[i] = thread.create_and_start_with_poly_data3(&queue, &mutex, t_id, process_item)
	}

	// Now we're going to use `join_multiple` to wait for all of our threads to stop processing.
	// This is why we're holding onto those threads in our array. You wouldn't want to just let them spin off 
	// and never check on them again!
	// 今度は `join_multiple` を使って、すべてのスレッドの処理が止まるのを待つ。これが、スレッドを配列に保持する理由だ。スレッドをスピンオフさせて二度とチェックしないようにするためだ
	//
	// `join_multiple` takes a variable number of Thread pointers (`^Thread`), and BLOCKS the main thread 
	// until each one of them is finished processing.
	// join_multiple` は可変数のスレッドポインタ (`^Thread`) を受け取り、それぞれのスレッドの処理が終わるまでメインスレッドをブロックする。
	//
	// Since we have an array of Thread pointers, we can use the `..` operator to expand all of the array 
	// items as arguments to `join_multiple`!
	// スレッドポインタの配列があるので、 `..` 演算子を使って `join_multiple` の引数として配列のすべての項目を展開することができる！
	thread.join_multiple(..threads[:])

	// Once the program ends, we'll clean up after ourselves by destroying each of these threads we created.
	for t in threads {
		thread.destroy(t)
	}

	// Everything's all finished now. Let's print out a "done" message and call it a day!
	fmt.printfln("Processed all items! Exiting.")
}
