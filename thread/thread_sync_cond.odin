package thread_sync_cond_2

import "core:fmt"
import "core:sync"
import "core:time"
import "core:thread"


worker1 :: proc(mtx: ^sync.Mutex, cv: ^sync.Cond, id: int) {
    duration := 500 * time.Millisecond
    fmt.printfln("Worker[ %d ]: START and waiting %v", id, duration)
    time.sleep(duration)
    if sync.mutex_guard(mtx) {
        fmt.printfln("Worker[ %d ]: sync.cond_broadcast()", id)
        sync.cond_broadcast(cv)
    } else {
        fmt.printfln("Worker[ %d ]: failed to lock mutex")
    }
    fmt.printfln("Worker[ %d ]: FINISH", id)
}

worker2 :: proc(mtx: ^sync.Mutex, cv: ^sync.Cond, id: int) {
    fmt.printfln("Worker[ %d ]: START and tring to lock mtx", id)
    sync.mutex_lock(mtx)
    defer sync.mutex_unlock(mtx)
    fmt.printfln("Worker[ %d ]: sync.cond_wait()", id)
    sync.cond_wait(cv, mtx)
    fmt.printfln("Worker[ %d ]: FINISH received notification of cv", id)
}

main :: proc() {
    fmt.println("--- START ---")

    mtx: sync.Mutex
    cv:  sync.Cond

    worker1_thread := thread.create_and_start_with_poly_data3(&mtx, &cv, 1, worker1)
    worker2_thread := thread.create_and_start_with_poly_data3(&mtx, &cv, 2, worker2)
    worker3_thread := thread.create_and_start_with_poly_data3(&mtx, &cv, 3, worker2)
    thread.join(worker1_thread)
    thread.join(worker2_thread)
    thread.join(worker3_thread)
}