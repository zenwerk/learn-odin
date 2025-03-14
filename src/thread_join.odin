package thread_join

import "core:fmt"
import "core:sync"
import "core:thread"
import "core:time"

wData :: struct {
	wg: ^sync.Wait_Group,
}

worker :: proc(t: ^thread.Thread) {
	duration := 3 * time.Second
	fmt.printfln("Worker: START and waiting %v", duration)
	time.sleep(duration)
	fmt.printfln("Worker: FINISH")
}

worker_with_wg :: proc(t: ^thread.Thread) {
	duration := 3 * time.Second
	th_data := cast(^wData)t.data
	defer sync.wait_group_done(th_data.wg)

	fmt.printfln("Worker with Wait_Group: START and waiting %v", duration)
	time.sleep(duration)
	fmt.printfln("Worker with Wait_Group: FINISH")
}


main :: proc() {
	fmt.println("--- START ---")

	// ループで待つ
	th := thread.create(worker)
	thread.start(th)

	fmt.println("Before join: thread.is_done(th) =", thread.is_done(th))
	for {
		if thread.is_done(th) {
			thread.join(th)
			break
		}
		time.sleep(10 * time.Millisecond)
	}
	fmt.println("After join:  thread.is_done(th) =", thread.is_done(th))
	thread.destroy(th)

	// Wait_Groupで待つ
	fmt.println("--- Wait_Group ---")
	wg := sync.Wait_Group{}
	th = thread.create(worker_with_wg)
	th.data = &wData{&wg}
	sync.wait_group_add(&wg, 1)

	thread.start(th)
	fmt.println("Before join: thread.is_done(th) =", thread.is_done(th))
	sync.wait_group_wait(&wg)

	thread.join(th)
	fmt.println("After join:  thread.is_done(th) =", thread.is_done(th))

	thread.destroy(th)
}

