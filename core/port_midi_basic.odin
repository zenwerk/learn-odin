package port_midi_basic

import "core:fmt"
import "core:time"
import "vendor:portmidi"


// 接続されているMIDIデバイスのリストを表示する
list_devices :: proc() {
	c := portmidi.CountDevices()
	if c == 0 {
		fmt.printfln("No MIDI devices found.")
		return
	}

	did := portmidi.GetDefaultInputDeviceID()
	fmt.printfln("Default MIDI input  device ID: %d", did)
	did = portmidi.GetDefaultOutputDeviceID()
	fmt.printfln("Default MIDI output device ID: %d", did)

	for i in 0 ..< c {
		di := portmidi.GetDeviceInfo(portmidi.DeviceID(i))
		fmt.printfln("Device %d: %v", i, di)
	}
}

// MIDIデバイスをオープンする
open_device :: proc() {
	stream: portmidi.Stream
	if err := portmidi.OpenOutput(&stream, portmidi.GetDefaultOutputDeviceID(), nil, 0, nil, nil, 0); err != .NoError {
		fmt.eprintfln("Failed to open MIDI device: %v", portmidi.GetErrorText(err))
		return
	}
	defer portmidi.Close(stream)

	// 送信するMIDIメッセージの作成
	// ノートオンメッセージ (ノート番号 60 (中央のC), ベロシティ 100)
	status_on: i32 = 0x90 // MIDIチャンネル1のノートオン
	note: i32 = 60
	velocity_on: i32 = 100
	message_on := portmidi.MessageMake(status_on, note, velocity_on)

	// ノートオフメッセージ (ノート番号 60, ベロシティ 0)
	status_off: i32 = 0x80 // MIDIチャンネル1のノートオフ
	velocity_off: i32 = 0
	message_off := portmidi.MessageMake(status_off, note, velocity_off)

	// メッセージを送信します [7].
	timestamp := portmidi.Timestamp(0) // すぐに送信

	fmt.println("ノートオンメッセージを送信...")
	if err := portmidi.WriteShort(stream, timestamp, message_on); err != .NoError {
		fmt.eprintln("ノートオンメッセージの送信に失敗しました:", portmidi.GetErrorText(err))
		return
	}

	// 少し待機します (必要に応じて調整してください)
	time.sleep(1 * time.Second)

	fmt.println("ノートオフメッセージを送信...")
	if err := portmidi.WriteShort(stream, timestamp, message_off); err != .NoError {
		fmt.eprintln("ノートオフメッセージの送信に失敗しました:", portmidi.GetErrorText(err))
		return
	}

	fmt.println("MIDIメッセージを送信しました.")
}


main :: proc() {
	if err := portmidi.Initialize(); err != .NoError {
		fmt.eprintfln("portmidi.Initialize() failed: %v", portmidi.GetErrorText(err))
		return
	}
	defer portmidi.Terminate()

	list_devices()
	open_device()
}
