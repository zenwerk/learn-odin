package thread_example

import "base:intrinsics"
import "core:fmt"
import "core:thread"
import "core:time"

prefix_table := [?]string{"White", "Red", "Green", "Blue", "Octarine", "Black"}

print_mutex := b64(false)

@(disabled = !thread.IS_SUPPORTED)
threading_example :: proc() {
	fmt.println("\n# threading_example")


	{ 	// Basic Threads
		fmt.println("\n## Basic Threads")

		worker_proc :: proc(t: ^thread.Thread) {
			for iteration in 1 ..= 5 {
				fmt.printf("Thread %d is on iteration %d\n", t.user_index, iteration)
				fmt.printf("`%s`: iteration %d\n", prefix_table[t.user_index], iteration)
				time.sleep(1 * time.Millisecond)
			}
		}

		threads := make([dynamic]^thread.Thread, 0, len(prefix_table))
		defer delete(threads)

		for _ in prefix_table {
			if t := thread.create(worker_proc); t != nil {
				t.init_context = context
				t.user_index = len(threads)
				append(&threads, t)
				thread.start(t)
			}
		}

		for len(threads) > 0 {
			for i := 0; i < len(threads);  /**/{
				if t := threads[i]; thread.is_done(t) {
					fmt.printf("Thread %d is done\n", t.user_index)
					thread.destroy(t)

					ordered_remove(&threads, i)
				} else {
					i += 1
				}
			}
		}
	}

	{ 	// Thread Pool
		fmt.println("\n## Thread Pool")

		did_acquire :: proc(m: ^b64) -> (acquired: bool) {
			res, ok := intrinsics.atomic_compare_exchange_strong(m, false, true)
			return ok && res == false
		}

		task_proc :: proc(t: thread.Task) {
			index := t.user_index % len(prefix_table)
			for iteration in 1 ..= 5 {
				for !did_acquire(&print_mutex) {thread.yield()} 	// Allow one thread to print at a time.

				fmt.printf("Worker Task %d is on iteration %d\n", t.user_index, iteration)
				fmt.printf("`%s`: iteration %d\n", prefix_table[index], iteration)

				print_mutex = false

				time.sleep(1 * time.Millisecond)
			}
		}

		N :: 3

		pool: thread.Pool
		thread.pool_init(&pool, allocator = context.allocator, thread_count = N)
		defer thread.pool_destroy(&pool)


		for i in 0 ..< 30 {
			// be mindful of the allocator used for tasks. The allocator needs to be thread safe, or be owned by the task for exclusive use
			thread.pool_add_task(
				&pool,
				allocator = context.allocator,
				procedure = task_proc,
				data = nil,
				user_index = i,
			)
		}

		thread.pool_start(&pool)

		{
			// Wait a moment before we cancel a thread
			time.sleep(5 * time.Millisecond)

			// Allow one thread to print at a time.
			for !did_acquire(&print_mutex) {thread.yield()}

			thread.terminate(pool.threads[N - 1], 0)
			fmt.println("Canceled last thread")
			print_mutex = false
		}

		thread.pool_finish(&pool)
	}
}

main :: proc() {
	threading_example()
}

