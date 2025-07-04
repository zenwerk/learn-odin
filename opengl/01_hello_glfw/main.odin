package main

import "core:fmt"
import gl "vendor:OpenGL"
import glfw "vendor:glfw"

main :: proc() {
	// GLFWライブラリを初期化する
	// GLFWはクロスプラットフォームなウィンドウ管理とOpenGLコンテキスト作成ライブラリ
	if !glfw.Init() {
		fmt.eprintln("Can't initialize GLFW")
		return
	}
	// プログラム終了時にGLFWをクリーンアップする
	defer glfw.Terminate()

	// OpenGLのバージョンとプロファイルを指定
	// Core Profileは古い機能を削除した新しいOpenGL仕様
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)                 // OpenGL 3.x
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 2)                 // OpenGL x.2
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE)         // 前方互換性を有効
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE) // Core Profileを使用

	// ウィンドウを作成する（幅640px、高さ480px、タイトル「Hello!」）
	// 返り値は「レンダリングコンテキスト」のポインタ
	window := glfw.CreateWindow(640, 480, "Hello!", nil, nil)
	if window == nil {
		fmt.eprintln("Can't create GLFW window.")
		return
	}

	// 作成したウィンドウのOpenGLコンテキストをカレント（現在の描画対象）にする
	// Current に指定したウィンドウに対して OpenGL の機能を使用できる
	glfw.MakeContextCurrent(window)

	// OpenGL関数ポインタを読み込む（OpenGL 3.2まで対応）
	gl.load_up_to(3, 2, glfw.gl_set_proc_address)

	// V-Syncを有効にする（画面のリフレッシュレートに同期）
	// 1 = 有効、0 = 無効
	glfw.SwapInterval(1)

	// 背景色を設定する（R=1.0, G=1.0, B=1.0, A=0.0 = 白色）
	gl.ClearColor(1.0, 1.0, 1.0, 0.0)

	// メインループ：ウィンドウが閉じられるまで繰り返す
	for !glfw.WindowShouldClose(window) {
		// フレームバッファをクリアする（前フレームの描画内容を消去）
		gl.Clear(gl.COLOR_BUFFER_BIT) // クリアしたいバッファ(カラーバッファ、デプスバッファ、ステンシルバッファ)をbitmaskで指定する

		// ここに3Dオブジェクトやテクスチャなどの描画処理を書く

		// ダブルバッファリング：裏画面と表画面を入れ替えて画面に表示
		glfw.SwapBuffers(window)

		// イベント処理：キーボード、マウス、ウィンドウイベントを処理
		// glfw.PollEvents でポーリングも可能
		glfw.WaitEvents()
	}
}