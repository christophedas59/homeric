extends GutTest

func test_manhattan_distance() -> void:
	var grid_manager := GridManager.new()
	assert_eq(grid_manager.manhattan(Vector2i(3, 3), Vector2i(16, 7)), 17)

func test_greedy_direction_prioritizes_x_when_abs_dx_is_larger_or_equal() -> void:
	var direction := Actor.choose_greedy_direction(Vector2i(3, 3), Vector2i(16, 7))
	assert_eq(direction, Vector2i(1, 0))

func test_greedy_direction_uses_y_when_abs_dy_is_larger() -> void:
	var direction := Actor.choose_greedy_direction(Vector2i(3, 3), Vector2i(4, 8))
	assert_eq(direction, Vector2i(0, 1))
