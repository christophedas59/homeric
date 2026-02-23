extends GutTest

const GridManagerScript = preload("res://scripts/grid_manager.gd")

class DummyActor:
	extends Node
	var cell: Vector2i = Vector2i.ZERO
	func set_cell_from_grid(new_cell: Vector2i) -> void:
		cell = new_cell

func test_cell_world_conversion_roundtrip() -> void:
	var gm := GridManagerScript.new()
	gm.cell_size = 64
	var cell := Vector2i(3, 5)
	var world := gm.cell_to_world(cell)
	assert_eq(world, Vector2(224, 352))
	assert_eq(gm.world_to_cell(world), cell)

func test_try_move_rejects_occupied_or_outside_grid() -> void:
	var gm := GridManagerScript.new()
	gm.grid_size = Vector2i(4, 4)
	var a := DummyActor.new()
	var b := DummyActor.new()
	assert_true(gm.add_actor(a, Vector2i(1, 1)))
	assert_true(gm.add_actor(b, Vector2i(2, 1)))
	assert_false(gm.try_move(a, Vector2i(2, 1)))
	assert_false(gm.try_move(a, Vector2i(6, 1)))

func test_reservation_blocks_double_entry_same_cell() -> void:
	var gm := GridManagerScript.new()
	gm.grid_size = Vector2i(6, 6)
	gm.begin_tick()
	var a := DummyActor.new()
	var b := DummyActor.new()
	assert_true(gm.add_actor(a, Vector2i(1, 1)))
	assert_true(gm.add_actor(b, Vector2i(1, 2)))
	assert_true(gm.reserve_move(a, Vector2i(2, 1)))
	assert_false(gm.reserve_move(b, Vector2i(2, 1)))
	gm.commit_reserved_moves()
	assert_eq(a.cell, Vector2i(2, 1))
	assert_eq(b.cell, Vector2i(1, 2))
