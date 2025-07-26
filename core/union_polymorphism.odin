package polymorphism_excircise

import "core:fmt"

// variant（discriminated union）を使った例
Shape :: union {
	Circle,
	Rectangle,
	Triangle,
}

Circle :: struct {
	radius: f32,
}

Rectangle :: struct {
	width, height: f32,
}

Triangle :: struct {
	base, height: f32,
}

// 各型に対する面積計算
area :: proc(shape: Shape) -> f32 {
	switch s in shape {
	case Circle:
		return 3.14159 * s.radius * s.radius
	case Rectangle:
		return s.width * s.height
	case Triangle:
		return 0.5 * s.base * s.height
	}
	return 0
}

// usingを使った構造体の合成
Animal :: struct {
	name: string,
	age:  int,
}

Dog :: struct {
	using animal: Animal, // Animalのフィールドを継承
	breed:        string,
}

Cat :: struct {
	using animal: Animal, // Animalのフィールドを継承
	indoor:       bool,
}

// インターフェース的な振る舞い（手続き型）
describe :: proc(animal: ^Animal) {
	fmt.printf("%s is %d years old\n", animal.name, animal.age)
}

// variant と using を組み合わせた例
Pet :: union {
	^Dog,
	^Cat,
}

feed :: proc(pet: Pet) {
	switch p in pet {
	case ^Dog:
		fmt.printf("Feeding dog %s with dog food\n", p.name)
	case ^Cat:
		fmt.printf("Feeding cat %s with cat food\n", p.name)
	}
}

main :: proc() {
	fmt.println("=== Union によるポリモーフィズム ===")

	shapes := [3]Shape{Circle{radius = 5}, Rectangle{width = 4, height = 6}, Triangle{base = 10, height = 8}}

	for shape in shapes {
		fmt.printf("Area: %.2f\n", area(shape))
	}

	fmt.println("\n=== Using による構造体の合成 ===")

	dog := Dog {
		animal = {name = "Max", age = 3},
		breed = "Golden Retriever",
	}

	cat := Cat {
		animal = {name = "Whiskers", age = 2},
		indoor = true,
	}

	// usingにより、親構造体のフィールドに直接アクセス可能
	fmt.printf("Dog name: %s, breed: %s\n", dog.name, dog.breed)
	fmt.printf("Cat name: %s, indoor: %v\n", cat.name, cat.indoor)

	// 親構造体へのポインタとして扱える
	describe(&dog.animal)
	describe(&cat.animal)

	fmt.println("\n=== Variant と Using の組み合わせ ===")

	pets := [2]Pet{&dog, &cat}

	for pet in pets {
		feed(pet)
	}
}

