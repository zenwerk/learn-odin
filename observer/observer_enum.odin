package observer_enum

import "core:fmt"

// オブザーバーのタイプを定義
ObserverType :: enum {
    Email,
    Log,
    Display,
}

// オブザーバーのベース構造体
Observer :: struct {
    type: ObserverType,
    id: int,
}

// 具体的なオブザーバーの実装
EmailObserver :: struct {
    using base: Observer,
    email_address: string,
}

LogObserver :: struct {
    using base: Observer,
    log_file: string,
}

DisplayObserver :: struct {
    using base: Observer,
    display_name: string,
}

// サブジェクト（観察対象）
Subject :: struct {
    observers: [dynamic]^Observer,
    state: string,
}

// サブジェクトの作成
create_subject :: proc() -> Subject {
    return Subject{
        observers = make([dynamic]^Observer),
        state = "",
    }
}

// サブジェクトの破棄
destroy_subject :: proc(subject: ^Subject) {
    delete(subject.observers)
}

// オブザーバーをサブジェクトに登録
attach_observer :: proc(subject: ^Subject, observer: ^Observer) {
    append(&subject.observers, observer)
    fmt.printf("オブザーバー (ID: %d) を登録しました\n", observer.id)
}

// オブザーバーをサブジェクトから削除
detach_observer :: proc(subject: ^Subject, observer: ^Observer) {
    for i := 0; i < len(subject.observers); i += 1 {
        if subject.observers[i] == observer {
            ordered_remove(&subject.observers, i)
            fmt.printf("オブザーバー (ID: %d) を削除しました\n", observer.id)
            break
        }
    }
}

// 全てのオブザーバーに通知
notify_observers :: proc(subject: ^Subject) {
    for observer in subject.observers {
        update_observer(observer, subject.state)
    }
}

// 状態を設定して通知
set_state :: proc(subject: ^Subject, new_state: string) {
    subject.state = new_state
    fmt.printf("\n[状態変更]: %s\n", new_state)
    notify_observers(subject)
}

// オブザーバーの更新処理（ポリモーフィック）
update_observer :: proc(observer: ^Observer, message: string) {
    switch observer.type {
    case .Email:
        email_obs := cast(^EmailObserver)observer
        fmt.printf("  📧 メール通知 [%s]: %s\n", email_obs.email_address, message)
        
    case .Log:
        log_obs := cast(^LogObserver)observer
        fmt.printf("  📝 ログ記録 [%s]: %s\n", log_obs.log_file, message)
        
    case .Display:
        display_obs := cast(^DisplayObserver)observer
        fmt.printf("  🖥️ ディスプレイ表示 [%s]: %s\n", display_obs.display_name, message)
    }
}

// オブザーバーの作成ヘルパー関数
create_email_observer :: proc(id: int, email: string) -> EmailObserver {
    return EmailObserver{
        base = Observer{type = .Email, id = id},
        email_address = email,
    }
}

create_log_observer :: proc(id: int, log_file: string) -> LogObserver {
    return LogObserver{
        base = Observer{type = .Log, id = id},
        log_file = log_file,
    }
}

create_display_observer :: proc(id: int, display_name: string) -> DisplayObserver {
    return DisplayObserver{
        base = Observer{type = .Display, id = id},
        display_name = display_name,
    }
}

main :: proc() {
    fmt.println("=== Observerパターンのサンプル ===\n")

    // サブジェクトを作成
    subject := create_subject()
    defer destroy_subject(&subject)

    // 各種オブザーバーを作成
    email_obs1 := create_email_observer(1, "admin@example.com")
    email_obs2 := create_email_observer(2, "user@example.com")
    log_obs := create_log_observer(3, "system.log")
    display_obs1 := create_display_observer(4, "メインディスプレイ")
    display_obs2 := create_display_observer(5, "サブディスプレイ")

    // オブザーバーを登録
    fmt.println("--- オブザーバーの登録 ---")
    attach_observer(&subject, cast(^Observer)&email_obs1)
    attach_observer(&subject, cast(^Observer)&log_obs)
    attach_observer(&subject, cast(^Observer)&display_obs1)

    // 状態変更と通知
    set_state(&subject, "システムが起動しました")
    set_state(&subject, "ユーザーがログインしました")

    // オブザーバーを追加
    fmt.println("\n--- 新しいオブザーバーを追加 ---")
    attach_observer(&subject, cast(^Observer)&email_obs2)
    attach_observer(&subject, cast(^Observer)&display_obs2)

    set_state(&subject, "データ処理を開始しました")

    // オブザーバーを削除
    fmt.println("\n--- オブザーバーを削除 ---")
    detach_observer(&subject, cast(^Observer)&email_obs1)
    detach_observer(&subject, cast(^Observer)&display_obs2)

    set_state(&subject, "処理が完了しました")

    // 登録されているオブザーバーの数を表示
    fmt.printf("\n現在登録されているオブザーバー数: %d\n", len(subject.observers))
}