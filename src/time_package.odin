package time_example

import "core:fmt"
import "core:time"
import "core:time/timezone"

print_jp_time :: proc(t: ^time.Time) {
	tz, _ := timezone.region_load("Asia/Tokyo")
	defer timezone.region_destroy(tz)

	dt, _ := time.time_to_datetime(t^)
	dt, _ = timezone.datetime_to_tz(dt, tz)
	fmt.printfln(
		"%04v/%02v/%02v %02v:%02v:%02v",
		dt.date.year,
		dt.date.month,
		dt.date.day,
		dt.time.hour,
		dt.time.minute,
		dt.time.second,
	)
}

duration_example :: proc() {
	tz, _ := timezone.region_load("Asia/Tokyo")
	defer timezone.region_destroy(tz)

	start_time := time.now()
	print_jp_time(&start_time)

	fmt.println("sleeping for 2 seconds")
	time.sleep(2 * time.Second) // 2秒間スリープ

	end_time := time.now()
	duration := time.diff(start_time, end_time)
	seconds := time.duration_seconds(duration)

	print_jp_time(&end_time)
	fmt.println("経過時間:", seconds, "秒")
}

// from: https://zenn.dev/ohkan/articles/b1c25abbd8b673
tick_example :: proc() {
	start, end: time.Tick

	fmt.printfln("--- 1度だけのtick時間表示")
	start = time.tick_now() // 開始時間取得
	time.sleep(100 * time.Millisecond)
	end = time.tick_now() // 終了時間取得
	duration := time.tick_diff(start, end)
	fmt.printfln("%v", duration) // 105.2744ms

	fmt.printfln("--- ラップ時間表示")
	start = time.tick_now()
	for i in 0 ..= 10 {
		time.sleep(200 * time.Millisecond)
		duration = time.tick_lap_time(&start)
		fmt.printfln("%v", duration) // ラップタイムが表示される 201.2114ms 202.5384ms ...
	}

	fmt.printfln("--- 増加時間表示")
	start = time.tick_now()
	for i in 0 ..= 10 {
		time.sleep(200 * time.Millisecond)
		duration = time.tick_since(start)
		fmt.printfln("%v", duration) // 増加分でタイムが表示 201.1117ms 402.7548ms ...
	}
}

main :: proc() {
	duration_example()

	tick_example()
}

