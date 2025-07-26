package arena_allocator_exircise

import "core:fmt"
import "core:os"

// virtualパッケージは多目的アリーナアロケータを実装している.
// 仮想メモリをサポートしていないプラットフォーム(WASMなど)であれば、`core:mem` を使用する.
import vmem "core:mem/virtual"

load_files :: proc() -> ([]string, vmem.Arena) {
	// 伸長する仮想メモリ・アリーナを作成. 仮想メモリーを使用しデータが追加されるにつれてメモリが伸長する.
	// arena_init_static で固定メモリ領域のアリーナを作成可能.
	// arena_init_buffer で仮想メモリを使用しないアリーナを作成可能.
	arena: vmem.Arena
	arena_err := vmem.arena_init_growing(&arena)
	ensure(arena_err == nil)
	arena_alloc := vmem.arena_allocator(&arena)

	// 以下でも同じ
	// level_arena: vmem.Arena
	// arena_allocator := vmem.arena_allocator(&level_arena)

	// arena_alloc を渡す
	f1, f1_ok := os.read_entire_file("for.odin", arena_alloc)
	ensure(f1_ok)
	f2, f2_ok := os.read_entire_file("slice.odin", arena_alloc)
	ensure(f2_ok)
	f3, f3_ok := os.read_entire_file("string.odin", arena_alloc)
	ensure(f3_ok)

	res := make([]string, 3, arena_alloc)
	res[0] = string(f1)
	res[1] = string(f2)
	res[2] = string(f3)

	return res, arena
}

main :: proc() {
	files, arena := load_files()

	for f in files {
		fmt.println(f)
	}

	// アリーナを解放すると f1, f2, f3 が同時に解放される.
	vmem.arena_destroy(&arena)
}

