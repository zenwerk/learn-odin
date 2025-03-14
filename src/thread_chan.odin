// from: https://yashdhadve.hashnode.dev/multi-threading-in-odin-lang#heading-communicating-between-threads-using-channels
package thread_chan

import "core:fmt"
import "core:sync"
import "core:sync/chan"
import "core:thread"
import time "core:time"

my_mutex: sync.Mutex

wData :: struct {
	wg: ^sync.Wait_Group,
	ch: ^chan.Chan(int),
}

main :: proc() {
	wg: sync.Wait_Group
	mchan, err := chan.create(chan.Chan(int), context.allocator)

	sender := thread.create(send_worker)
	sender.user_index = 1
	sender.data = &wData{wg = &wg, ch = &mchan}

	receiver := thread.create(recv_worker)
	receiver.user_index = 2
	receiver.data = &wData{wg = &wg, ch = &mchan}

	receiver2 := thread.create(recv_worker)
	receiver2.user_index = 3
	receiver2.data = &wData{wg = &wg, ch = &mchan}

	sync.wait_group_add(&wg, 3)
	thread.start(sender)
	thread.start(receiver)
	thread.start(receiver2)
	sync.wait_group_wait(&wg)
}

send_worker :: proc(t: ^thread.Thread) {
	fmt.printf("work of sender started \n")
	th_data := (cast(^wData)t.data)

	// passing 24 through our channel
	// now this 24 can be picked up by other threads using this channel
	time.sleep(1 * time.Second)
	ok := chan.send(th_data.ch^, 24)
	if ok {
		fmt.println("sender sent message via chan")
	} else {
		fmt.println("couldn't send message")
	}

	sync.wait_group_done(th_data.wg)
}

recv_worker :: proc(t: ^thread.Thread) {
	fmt.printf("work of recver started no %d\n", t.user_index)
	th_data := (cast(^wData)t.data)

	// This will wait here till we recieve any data through channel
	// once we get data from channel we can move forward
	data, ok := chan.recv(th_data.ch^)
	if ok {
		fmt.printf("Recieved %d from sender: t.id=%d\n", data, t.user_index)
	} else {
		fmt.printf("Something went wrong\n")
	}

	sync.wait_group_done(th_data.wg)
}

