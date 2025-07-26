package observer_proc

import "core:fmt"

// オブザーバーインターフェース
Observer :: struct {
    update: proc(observer: ^Observer, message: string),
    data: rawptr,
}

// オブザーバーのリストを管理するサブジェクト
Subject :: struct {
    observers: [dynamic]^Observer,
    state: string,
}

// 新しいサブジェクトを作成
subject_create :: proc() -> Subject {
    return Subject{
        observers = make([dynamic]^Observer),
        state = "",
    }
}

// サブジェクトを破棄してクリーンアップ
subject_destroy :: proc(subject: ^Subject) {
    delete(subject.observers)
}

// オブザーバーをサブジェクトに登録
subject_attach :: proc(subject: ^Subject, observer: ^Observer) {
    append(&subject.observers, observer)
}

// オブザーバーをサブジェクトから削除
subject_detach :: proc(subject: ^Subject, observer: ^Observer) {
    for i := 0; i < len(subject.observers); i += 1 {
        if subject.observers[i] == observer {
            ordered_remove(&subject.observers, i)
            break
        }
    }
}

// 状態変更を全てのオブザーバーに通知
subject_notify :: proc(subject: ^Subject) {
    for observer in subject.observers {
        observer.update(observer, subject.state)
    }
}

// 状態を設定してオブザーバーに通知
subject_set_state :: proc(subject: ^Subject, state: string) {
    subject.state = state
    subject_notify(subject)
}

// 具体的なオブザーバーの実装
EmailNotifier :: struct {
    name: string,
}

email_update :: proc(observer: ^Observer, message: string) {
    notifier := cast(^EmailNotifier)observer.data
    fmt.printf("メール通知 [%s]: 新しいメッセージ - %s\n", notifier.name, message)
}

LogObserver :: struct {
    log_file: string,
}

log_update :: proc(observer: ^Observer, message: string) {
    logger := cast(^LogObserver)observer.data
    fmt.printf("ロガー [%s]: 記録中 - %s\n", logger.log_file, message)
}

DisplayObserver :: struct {
    display_id: int,
}

display_update :: proc(observer: ^Observer, message: string) {
    display := cast(^DisplayObserver)observer.data
    fmt.printf("ディスプレイ %d: 表示中 - %s\n", display.display_id, message)
}

main :: proc() {
    fmt.println("=== オブザーバーパターンの例 ===\n")

    // サブジェクトを作成
    subject := subject_create()
    defer subject_destroy(&subject)

    // 具体的なオブザーバーを作成
    email_notifier := EmailNotifier{name = "admin@example.com"}
    email_observer := Observer{
        update = email_update,
        data = &email_notifier,
    }

    log_observer_data := LogObserver{log_file = "app.log"}
    log_observer := Observer{
        update = log_update,
        data = &log_observer_data,
    }

    display_observer_data := DisplayObserver{display_id = 1}
    display_observer := Observer{
        update = display_update,
        data = &display_observer_data,
    }

    // オブザーバーを登録
    fmt.println("オブザーバーを登録中...")
    subject_attach(&subject, &email_observer)
    subject_attach(&subject, &log_observer)
    subject_attach(&subject, &display_observer)

    // 状態を変更して通知
    fmt.println("\n最初の状態変更:")
    subject_set_state(&subject, "システムが起動しました")

    fmt.println("\n2回目の状態変更:")
    subject_set_state(&subject, "ユーザーがログインしました")

    // オブザーバーを1つ削除
    fmt.println("\nメールオブザーバーを削除中...")
    subject_detach(&subject, &email_observer)

    fmt.println("\n3回目の状態変更:")
    subject_set_state(&subject, "データを処理中")

    // 別のディスプレイオブザーバーを作成
    display_observer_data2 := DisplayObserver{display_id = 2}
    display_observer2 := Observer{
        update = display_update,
        data = &display_observer_data2,
    }

    fmt.println("\n2つ目のディスプレイオブザーバーを登録中...")
    subject_attach(&subject, &display_observer2)

    fmt.println("\n4回目の状態変更:")
    subject_set_state(&subject, "操作が完了しました")
}