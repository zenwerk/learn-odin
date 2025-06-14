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
        "SDL3 図形描画サンプル - 三角形と四角形",
        800, 600,
        {.RESIZABLE} // リサイズ可能なウィンドウ
    )
    if window == nil {
        fmt.eprintln("ウィンドウの作成に失敗しました")
        return
    }
    defer sdl3.DestroyWindow(window) // ウィンドウのクリーンアップ

    // ソフトウェアレンダラーを作成
    // CreateRenderer関数を使用してソフトウェアレンダリングを指定
    renderer := sdl3.CreateRenderer(window, nil)
    if renderer == nil {
        fmt.eprintln("レンダラーの作成に失敗しました")
        return
    }
    defer sdl3.DestroyRenderer(renderer) // レンダラーのクリーンアップ

    // メインループフラグ
    running := true

    fmt.println("SDL3図形描画プログラムが起動しました")
    fmt.println("三角形と四角形を表示します")
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

        // 画面をクリア（黒色で塗りつぶす）
        sdl3.SetRenderDrawColor(renderer, 0, 0, 0, 255)
        sdl3.RenderClear(renderer)

        // 四角形を描画（青色）
        // 左側に配置
        sdl3.SetRenderDrawColor(renderer, 0, 0, 255, 255)
        rect := sdl3.FRect{100, 200, 200, 200} // x, y, 幅, 高さ
        sdl3.RenderFillRect(renderer, &rect)

        // 三角形を描画（赤色）
        // 右側に配置
        // SDL3では三角形を直接描画する関数がないため、
        // RenderGeometryを使用して頂点データから描画する
        sdl3.SetRenderDrawColor(renderer, 255, 0, 0, 255)
        
        // 三角形の頂点データ
        vertices := [3]sdl3.Vertex{
            // 頂点1: 上部中央
            {position = {500, 150}, color = {255, 0, 0, 255}},
            // 頂点2: 左下
            {position = {400, 350}, color = {255, 0, 0, 255}},
            // 頂点3: 右下
            {position = {600, 350}, color = {255, 0, 0, 255}},
        }
        
        // 三角形を描画
        sdl3.RenderGeometry(renderer, nil, &vertices[0], 3, nil, 0)

        // 描画内容を画面に反映
        sdl3.RenderPresent(renderer)

        // 60FPSに制限（約16.67ms待機）
        time.sleep(16 * time.Millisecond)
    }

    fmt.println("プログラムを終了します")
}