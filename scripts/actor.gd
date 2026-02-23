extends AnimatedSprite2D
class_name Actor

@export var cell: Vector2i = Vector2i.ZERO
@export var target_path: NodePath
@export var grid_manager_path: NodePath
@export var move_interval: float = 0.25
@export var interpolation_speed: float = 12.0

var target_cell: Vector2i = Vector2i.ZERO
var _move_timer: float = 0.0
var _grid_manager: GridManager
var _target_actor: Actor

func _ready() -> void:
	_grid_manager = get_node_or_null(grid_manager_path) as GridManager
	_target_actor = get_node_or_null(target_path) as Actor
	if _grid_manager == null:
		push_error("Actor '%s' is missing a valid GridManager node path." % name)
		set_process(false)
		return

	target_cell = cell
	position = _grid_manager.cell_to_world(cell)

func _process(delta: float) -> void:
	if _target_actor == null:
		_target_actor = get_node_or_null(target_path) as Actor

	_move_timer += delta
	while _move_timer >= move_interval:
		_move_timer -= move_interval
		_step_towards_target()

	var target_world: Vector2 = _grid_manager.cell_to_world(cell)
	var alpha: float = clampf(delta * interpolation_speed, 0.0, 1.0)
	position = position.lerp(target_world, alpha)

func _step_towards_target() -> void:
	if _target_actor == null:
		return

	target_cell = _target_actor.cell
	var direction: Vector2i = choose_greedy_direction(cell, target_cell)
	if direction == Vector2i.ZERO:
		return

	cell = _grid_manager.clamp_cell(cell + direction)
	print("%s -> %s" % [name, cell])

static func choose_greedy_direction(from_cell: Vector2i, to_cell: Vector2i) -> Vector2i:
	var dx: int = to_cell.x - from_cell.x
	var dy: int = to_cell.y - from_cell.y

	if dx == 0 and dy == 0:
		return Vector2i.ZERO

	if absi(dx) >= absi(dy):
		if dx != 0:
			return Vector2i(signi(dx), 0)
		if dy != 0:
			return Vector2i(0, signi(dy))
	else:
		if dy != 0:
			return Vector2i(0, signi(dy))
		if dx != 0:
			return Vector2i(signi(dx), 0)

	return Vector2i.ZERO
