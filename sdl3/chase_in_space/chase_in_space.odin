/*
	Simple game about enemies chasing and shooting you in 2D space.

	Original repo: https://github.com/wbogocki/Odin-Play

	To play / 操作方法:
		- Move with WSAD or arrow keys / WASDまたは矢印キーで移動
		- Jump with Shift + direction / Shift + 方向キーでダッシュ
*/

package chase_in_space

import "core:c"
import "core:fmt"
import "core:math/linalg"
import "vendor:sdl3"

// ゲームの状態を管理する構造体
Game :: struct {
	renderer: ^sdl3.Renderer,     // SDL3のレンダラー（描画に使用）
	keyboard: [^]bool,            // キーボードの状態（どのキーが押されているか）
	time:     f64,                // 現在の時刻（ミリ秒）
	dt:       f64,                // デルタタイム（前フレームからの経過時間）
	entities: [dynamic]Entity,    // ゲーム内のすべてのエンティティ（プレイヤー、敵、弾丸）
}

// エンティティの種類を表す列挙型
EntityType :: enum {
	PLAYER,      // プレイヤー
	ENEMY,       // 敵
	PROJECTILE,  // 弾丸
}

// ゲーム内のオブジェクト（プレイヤー、敵、弾丸）を表す構造体
Entity :: struct {
	type:           EntityType,  // エンティティの種類
	hp:             int,         // ヒットポイント（体力）
	pos:            [2]f32,      // 位置 [x, y]
	vel:            [2]f32,      // 速度ベクトル [vx, vy]
	reload_counter: f32,         // 次の弾を撃てるまでの時間（敵用）
	bullet_decay:   f32,         // 弾丸の寿命（弾丸用）
	dash_counter:   f32,         // ダッシュのクールダウン時間（プレイヤー用）
}

// エンティティを画面に描画する関数
render_entity :: proc(entity: ^Entity, game: ^Game) {
	switch entity.type {
	case .PLAYER:
		// プレイヤーは紫色の四角形で表示
		sdl3.SetRenderDrawColor(game.renderer, 255, 0, 255, 255)  // RGBA(255, 0, 255, 255) = 紫色
		sdl3.RenderFillRect(
			game.renderer,
			&sdl3.FRect{x = entity.pos.x, y = entity.pos.y, w = 10, h = 10},  // 10x10ピクセルの四角形
		)
	case .ENEMY:
		// 敵は水色の四角形で表示
		sdl3.SetRenderDrawColor(game.renderer, 0, 255, 255, 255)  // RGBA(0, 255, 255, 255) = 水色
		sdl3.RenderFillRect(
			game.renderer,
			&sdl3.FRect{x = entity.pos.x, y = entity.pos.y, w = 10, h = 10},  // 10x10ピクセルの四角形
		)
	case .PROJECTILE:
		// 弾丸は水色の点で表示
		sdl3.SetRenderDrawColor(game.renderer, 0, 255, 255, 255)     // RGBA(0, 255, 255, 255) = 水色
		sdl3.RenderPoint(game.renderer, entity.pos.x, entity.pos.y)  // 1ピクセルの点
	}
}

// 指定したタイプのエンティティを検索する関数
find_entity :: proc(type: EntityType, game: ^Game) -> ^Entity {
	for _, i in game.entities {
		if game.entities[i].type == type {
			return &game.entities[i]
		}
	}
	return nil
}

// エンティティの状態を更新する関数（毎フレーム呼ばれる）
update_entity :: proc(entity: ^Entity, game: ^Game) {
	dt := f32(game.dt)  // デルタタイムをf32型に変換
	switch entity.type {
	case .PLAYER:
		// プレイヤーの移動処理
		dir := [2]f32{0, 0}  // 移動方向ベクトル
		// キー入力をチェックして移動方向を決定
		if game.keyboard[sdl3.Scancode.UP   ] | game.keyboard[sdl3.Scancode.W] { dir.y -= 1 }  // 上
		if game.keyboard[sdl3.Scancode.DOWN ] | game.keyboard[sdl3.Scancode.S] { dir.y += 1 }  // 下
		if game.keyboard[sdl3.Scancode.LEFT ] | game.keyboard[sdl3.Scancode.A] { dir.x -= 1 }  // 左
		if game.keyboard[sdl3.Scancode.RIGHT] | game.keyboard[sdl3.Scancode.D] { dir.x += 1 }  // 右
		dir = linalg.normalize0(dir)  // ベクトルを正規化（長さを1にする）
		entity.pos += dir * 0.2 * dt  // 通常の移動速度で位置を更新
		
		// ダッシュ機能
		if game.keyboard[sdl3.Scancode.LSHIFT] && entity.dash_counter == 0 && dir != 0 {
			// Shiftキーが押され、クールダウンが終了し、移動方向が指定されている場合
			entity.vel = dir * 5.0          // ダッシュ速度を設定
			entity.dash_counter += 150      // クールダウンタイマーをセット
		} else {
			entity.dash_counter = max(entity.dash_counter - dt, 0)  // クールダウンタイマーを減らす
		}
		entity.pos += entity.vel * dt           // 速度による位置更新
		entity.vel -= entity.vel * 0.9999 / dt  // 速度を徐々に減衰させる
		
		// 画面外に出ないように制限
		entity.pos.x = clamp(entity.pos.x, 0, 640 - 10)  // x座標を0〜630の範囲に制限
		entity.pos.y = clamp(entity.pos.y, 0, 480 - 10)  // y座標を0〜470の範囲に制限
	case .ENEMY:
		// 敵の AI 処理
		// プレイヤーに向かって移動
		player := find_entity(.PLAYER, game)
		if player == nil { return }     // プレイヤーが見つからなければ処理を終了
		dir := player.pos - entity.pos  // プレイヤーへの方向ベクトル
		dir = linalg.normalize0(dir)    // 正規化
		entity.pos += dir * 0.12 * dt   // プレイヤーに向かって移動（速度: 0.12）
		
		// 他の敵から離れる（群れの動作を防ぐ）
		for _, i in game.entities {
			if game.entities[i].type == .ENEMY && entity != &game.entities[i] {
				edir := entity.pos - game.entities[i].pos  // 他の敵から自分への方向ベクトル
				dis  := linalg.length(edir)                // 距離を計算
				if dis > 0 {
					// 距離の二乗に反比例する力で離れる（近いほど強く反発）
					entity.pos += edir * (1. / (dis * dis)) * 0.1 * dt
				}
			}
		}
		
		// 弾を撃つ処理
		if entity.reload_counter <= 0 {
			// リロード完了時に弾を生成
			append(
				&game.entities,
				Entity{
					type = .PROJECTILE,   // 弾丸タイプ
					pos = entity.pos,     // 敵の位置から発射
					vel = 0.5 * dir,      // プレイヤーの方向に速度0.5で飛ぶ
					hp = 1,               // 弾のHP（1回ヒットで消える）
					bullet_decay = 750,   // 弾の寿命（750ミリ秒）
				},
			)
			entity.reload_counter = 1000  // 次の弾まで1000ミリ秒待機
		} else {
			entity.reload_counter -= dt   // リロードカウンターを減らす
		}
	case .PROJECTILE:
		// 弾丸の処理
		entity.pos += entity.vel * dt     // 速度に基づいて位置を更新
		entity.bullet_decay -= 1.0 * dt   // 寿命を減らす
		if entity.bullet_decay < 0 {
			entity.hp = 0  // 寿命が尽きたら削除対象にする
		} else {
			// プレイヤーとの当たり判定
			player := find_entity(.PLAYER, game)
			if player == nil { return }
			// 弾がプレイヤーの四角形内にあるかチェック
			if player.pos.x < entity.pos.x && entity.pos.x < player.pos.x + 10 && 
			   player.pos.y < entity.pos.y && entity.pos.y < player.pos.y + 10 {
				player.hp -= 1                              // プレイヤーのHPを1減らす
				fmt.printf("HIT (HP: {})\\n", player.hp)    // ヒット時のログ出力
				entity.hp = 0                               // 弾は消える
			}
		}
	}
}

// 高精度タイマーを使って現在時刻を取得する関数（ミリ秒単位）
get_time :: proc() -> f64 {
	// SDL3の高精度タイマーを使用
	// GetPerformanceCounter: CPU のタイマーカウント値を取得
	// GetPerformanceFrequency: 1秒あたりのカウント数を取得
	return f64(sdl3.GetPerformanceCounter()) * 1000 / f64(sdl3.GetPerformanceFrequency())
}

// メイン関数（プログラムのエントリーポイント）
main :: proc() {
	// SDL3を初期化（ビデオサブシステムのみ使用）
	assert(sdl3.Init({.VIDEO}), string(sdl3.GetError()))
	defer sdl3.Quit()  // 関数終了時にSDL3を終了

	// ゲームウィンドウを作成
	window := sdl3.CreateWindow(
		"Odin Game",  // ウィンドウタイトル
		640,          // 幅（ピクセル）
		480,          // 高さ（ピクセル）
		{},           // ウィンドウフラグ（今回は何も指定しない）
	)
	assert(window != nil, string(sdl3.GetError()))
	defer sdl3.DestroyWindow(window)  // 関数終了時にウィンドウを破棄

	// レンダラー（描画エンジン）を作成
	// 注意: VSyncは使わない（ゲームループと描画が同じスレッドで動作するため）
	renderer := sdl3.CreateRenderer(window, nil)
	assert(renderer != nil, string(sdl3.GetError()))
	defer sdl3.DestroyRenderer(renderer)  // 関数終了時にレンダラーを破棄

	// ゲームのティックレート設定（1秒間に何回更新するか）
	tickrate := 240.0               // 240Hz（1秒間に240回更新）
	ticktime := 1000.0 / tickrate   // 1ティックあたりの時間（ミリ秒）

	// ゲーム状態を初期化
	game := Game {
		renderer = renderer,               // レンダラーを設定
		time     = get_time(),             // 現在時刻を取得
		dt       = ticktime,               // デルタタイムを設定
		entities = make([dynamic]Entity),  // エンティティの動的配列を作成
	}
	defer delete(game.entities)  // 関数終了時にメモリを解放

	// 初期エンティティを配置
	append(&game.entities, Entity{type = .PLAYER, pos = { 50.0, 400.0}, hp = 10})  // プレイヤー（左下）
	append(&game.entities, Entity{type = .ENEMY , pos = { 50.0,  50.0}, hp =  1})   // 敵1（左上）
	append(&game.entities, Entity{type = .ENEMY , pos = {100.0, 100.0}, hp =  1})   // 敵2（中央上）
	append(&game.entities, Entity{type = .ENEMY , pos = {200.0, 200.0}, hp =  1})   // 敵3（中央）

	dt := 0.0  // 累積デルタタイム（固定フレームレート実現用）

	// メインループ
	for {
		// イベント処理
		event: sdl3.Event
		for sdl3.PollEvent(&event) {  // 保留中のイベントをすべて処理
			#partial switch event.type {
			case .QUIT:
				return  // ウィンドウの×ボタンが押されたら終了
			case .KEY_DOWN:
				if event.key.scancode == sdl3.Scancode.ESCAPE {
					return  // ESCキーが押されたら終了
				}
			}
		}

		// 時間の更新
		time := get_time()        // 現在時刻を取得
		dt += time - game.time    // 前フレームからの経過時間を累積

		// キーボード状態を取得
		numkeys: c.int
		game.keyboard = sdl3.GetKeyboardState(&numkeys)  // 全キーの押下状態を取得
		game.time = time  // 現在時刻を保存

		// 固定タイムステップでゲーム状態を更新
		// 累積時間がティック時間を超えたら更新処理を実行
		for dt >= ticktime {
			dt -= ticktime  // ティック時間分を減算

			// すべてのエンティティを更新
			for _, i in game.entities {
				update_entity(&game.entities[i], &game)
			}

			// HPが0以下のエンティティを削除
			for i := 0; i < len(game.entities); {
				if game.entities[i].hp <= 0 {
					ordered_remove(&game.entities, i)  // 順序を保って削除
				} else {
					i += 1  // 削除しなかった場合のみインデックスを進める
				}
			}
		}

		// 画面の描画
		sdl3.SetRenderDrawColor(renderer, 0, 0, 0, 255)  // 背景色を黒に設定
		sdl3.RenderClear(renderer)                       // 画面をクリア
		
		// すべてのエンティティを描画
		for _, i in game.entities {
			render_entity(&game.entities[i], &game)
		}
		
		sdl3.RenderPresent(renderer)  // 描画内容を画面に反映
	}
}