package main

import "vendor:sdl3"
import "core:fmt"
import "core:time"

main :: proc() {
    // SDL3を初期化 (ビデオとイベントサブシステムを有効化)
    if !sdl3.Init({.VIDEO, .EVENTS}) {
        fmt.eprintln("SDL3の初期化に失敗しました")
        return
    }
    defer sdl3.Quit() // プログラム終了時にSDL3をクリーンアップ

    // ウィンドウを作成
    // 引数: タイトル, 幅, 高さ, フラグ
    window := sdl3.CreateWindow(
        "SDL3 最小サンプル",
        800, 600,
        {.RESIZABLE} // リサイズ可能なウィンドウ
    )
    if window == nil {
        fmt.eprintln("ウィンドウの作成に失敗しました")
        return
    }
    defer sdl3.DestroyWindow(window) // ウィンドウのクリーンアップ

    // メインループフラグ
    running := true

    fmt.println("SDL3ウィンドウが起動しました")
    fmt.println("ウィンドウを閉じるか、Escキーで終了します")

    // メインループ
    for running {
        // イベント処理
        event: sdl3.Event
        for sdl3.PollEvent(&event) {
            #partial switch event.type {
            case .QUIT:
                // ウィンドウの閉じるボタンが押された
                running = false

            case .KEY_DOWN:
                // キーが押された
                key_event := cast(^sdl3.KeyboardEvent)&event
                if key_event.key == sdl3.K_ESCAPE {
                    // Escキーで終了
                    running = false
                }
            }
        }

        // 60FPSに制限（約16.67ms待機）
        time.sleep(16 * time.Millisecond)
    }

    fmt.println("プログラムを終了します")
}