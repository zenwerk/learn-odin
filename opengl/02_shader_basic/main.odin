package main

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"

// シェーダーオブジェクトのコンパイル結果を表示する関数
// シェーダー: GPU上で頂点やピクセルの処理を行うプログラム
print_shader_info_log :: proc(shader: u32, str: cstring) -> bool {
	// シェーダーのコンパイル状態を取得
	// 0 = コンパイル失敗、0以外 = コンパイル成功
	status: i32
	gl.GetShaderiv(shader, gl.COMPILE_STATUS, &status)
	if status == 0 {
		fmt.eprintln("Compile Error in", str)
	}

	// エラーメッセージの長さを取得
	buf_size: i32
	gl.GetShaderiv(shader, gl.INFO_LOG_LENGTH, &buf_size)

	if buf_size > 1 {
		// エラーメッセージを取得して表示
		info_log := make([]u8, buf_size)
		defer delete(info_log)  // メモリを自動的に解放
		length: i32
		gl.GetShaderInfoLog(shader, buf_size, &length, raw_data(info_log))
		fmt.eprintln(string(info_log[:length]))
	}

	return status != 0
}

// プログラムオブジェクトのリンク結果を表示する関数
// リンク: 頂点シェーダーとフラグメントシェーダーを結合する処理
print_program_info_log :: proc(program: u32) -> bool {
	// リンク状態を取得
	status: i32
	gl.GetProgramiv(program, gl.LINK_STATUS, &status)
	if status == 0 {
		fmt.eprintln("Link Error.")
	}

	// エラーメッセージの長さを取得
	buf_size: i32
	gl.GetProgramiv(program, gl.INFO_LOG_LENGTH, &buf_size)

	if buf_size > 1 {
		// エラーメッセージを取得して表示
		info_log := make([]u8, buf_size)
		defer delete(info_log)
		length: i32
		gl.GetProgramInfoLog(program, buf_size, &length, raw_data(info_log))
		fmt.eprintln(string(info_log[:length]))
	}

	return status != 0
}

// シェーダープログラムを作成する関数
// vsrc: 頂点シェーダーのソースコード（頂点の位置を計算）
// fsrc: フラグメントシェーダーのソースコード（ピクセルの色を計算）
create_program :: proc(vsrc: cstring, fsrc: cstring) -> u32 {
	// 空のプログラムオブジェクトを作成
	// プログラム: 頂点シェーダーとフラグメントシェーダーを組み合わせたもの
	program := gl.CreateProgram()

	if vsrc != nil {
		// 頂点シェーダーを作成
		// 頂点シェーダー: 各頂点の画面上の位置を計算する
		vobj := gl.CreateShader(gl.VERTEX_SHADER)
		vsrc_ptr := vsrc
		gl.ShaderSource(vobj, 1, &vsrc_ptr, nil)  // ソースコードを設定
		gl.CompileShader(vobj)  // コンパイル実行

		// コンパイル成功時はプログラムに追加
		if print_shader_info_log(vobj, "vertex shader") {
			gl.AttachShader(program, vobj)
		}
		gl.DeleteShader(vobj)  // シェーダーオブジェクトは不要になったので削除
	}

	if fsrc != nil {
		// フラグメントシェーダーを作成
		// フラグメントシェーダー: 各ピクセルの色を計算する
		fobj := gl.CreateShader(gl.FRAGMENT_SHADER)
		fsrc_ptr := fsrc
		gl.ShaderSource(fobj, 1, &fsrc_ptr, nil)
		gl.CompileShader(fobj)

		// コンパイル成功時はプログラムに追加
		if print_shader_info_log(fobj, "fragment shader") {
			gl.AttachShader(program, fobj)
		}
		gl.DeleteShader(fobj)
	}

	// シェーダープログラムをリンク
	// 頂点データの入力位置を指定（location = 0 に "position" を割り当て）
	gl.BindAttribLocation(program, 0, "position")
	// 出力先を指定（location = 0 に "fragment" を割り当て）
	gl.BindFragDataLocation(program, 0, "fragment")
	// リンク実行
	gl.LinkProgram(program)

	// リンク成功時はプログラムを返す
	if print_program_info_log(program) {
		return program
	}

	// 失敗時はプログラムを削除して0を返す
	gl.DeleteProgram(program)
	return 0
}

main :: proc() {
	// GLFW（ウィンドウ管理ライブラリ）を初期化
	if !glfw.Init() {
		fmt.eprintln("Can't initialize GLFW")
		return
	}
	defer glfw.Terminate()  // プログラム終了時に自動的にクリーンアップ

	// OpenGL Version 3.2 Core Profile を使用
	// Core Profile: 古い機能を削除したモダンな OpenGL
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 2)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, 1)  // 将来の互換性を確保
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	// 640x480 ピクセルのウィンドウを作成
	window := glfw.CreateWindow(640, 480, "Hello!", nil, nil)
	if window == nil {
		fmt.eprintln("Can't create GLFW window.")
		return
	}
	defer glfw.DestroyWindow(window)

	// 作成したウィンドウを OpenGL の描画対象に設定
	glfw.MakeContextCurrent(window)

	// OpenGL の関数を読み込み（OpenGL 3.2 まで）
	gl.load_up_to(3, 2, glfw.gl_set_proc_address)

	// V-Sync を有効化（画面のリフレッシュレートに同期）
	glfw.SwapInterval(1)

	// 背景色を白色に設定（RGBA: 1.0, 1.0, 1.0, 0.0）
	gl.ClearColor(1.0, 1.0, 1.0, 0.0)

	// 頂点シェーダーのソースコード
	// gl_Position: 頂点の最終的な位置を指定する組み込み変数
	vsrc := `#version 150 core
in vec2 position;
void main(void)
{
  gl_Position = vec4(position, 0.0, 1.0);
}
`


	// フラグメントシェーダーのソースコード
	// fragment: 出力するピクセルの色（RGBA）
	fsrc := `#version 150 core
out vec4 fragment;
void main(void)
{
  fragment = vec4(1.0, 0.0, 0.0, 1.0);
}
`


	// シェーダープログラムを作成
	program := create_program(cstring(raw_data(vsrc)), cstring(raw_data(fsrc)))
	if program == 0 {
		fmt.eprintln("Failed to create program")
		return
	}
	fmt.println("Program created:", program)

	// VAO（Vartex Array Object = 頂点配列オブジェクト）を作成
	// VAO: 頂点データの設定をまとめて管理するオブジェクト
	vao: u32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)  // 現在の VAO として設定
	fmt.println("VAO:", vao)

	// VBO（頂点バッファオブジェクト）を作成
	// VBO: 頂点データを GPU メモリに保存するオブジェクト
	vbo: u32
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)  // 現在の VBO として設定

	// 三角形の頂点座標を定義
	// 2D座標系で3つの頂点（各頂点は x, y の2要素）
	// 座標系: -1.0 〜 1.0 の範囲（正規化デバイス座標）
	vertices := [?]f32 {
		-0.5, -0.5,  // 左下の頂点
		 0.5, -0.5,  // 右下の頂点
		 0.0,  0.5,  // 上の頂点
	}

	// 頂点データを GPU メモリに転送
	// STATIC_DRAW: データは変更されず、何度も描画に使用される
	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

	// 頂点属性を有効化（location = 0 の属性を使用）
	gl.EnableVertexAttribArray(0)
	// 頂点属性の詳細を設定
	// 引数: location, 要素数, データ型, 正規化, ストライド, オフセット
	gl.VertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0)

	// VAO の設定を終了（バインドを解除）
	gl.BindVertexArray(0)

	// メインループ：ウィンドウが閉じられるまで繰り返す
	for !glfw.WindowShouldClose(window) {
		// 画面をクリア（背景色で塗りつぶす）
		gl.Clear(gl.COLOR_BUFFER_BIT)

		// シェーダープログラムを使用開始
		gl.UseProgram(program)

		// VAO をバインドして三角形を描画
		gl.BindVertexArray(vao)
		// TRIANGLES: 3つの頂点で1つの三角形を描画
		gl.DrawArrays(gl.TRIANGLES, 0, 3)

		// ダブルバッファリング：描画完了後に画面を切り替え
		// これにより、描画中の画面がちらつかない
		glfw.SwapBuffers(window)

		// イベント（キー入力、マウス操作など）を処理
		glfw.WaitEvents()
	}
}