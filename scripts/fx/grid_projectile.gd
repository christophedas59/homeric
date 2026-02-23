extends Node2D
class_name GridProjectile

signal hit(cell: Vector2i, occupant: GridActor, payload: Dictionary)
signal finished

var grid_manager: GridManager
var source: GridActor
var direction: Vector2i = Vector2i.RIGHT
var range_cells: int = 5
var step_time: float = 0.08
var traveled: int = 0
var current_cell: Vector2i
var payload: Dictionary = {}

var _step_acc: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func setup(manager: GridManager, config: Dictionary) -> void:
	grid_manager = manager
	source = config.get("source")
	current_cell = config.get("start_cell", Vector2i.ZERO)
	direction = config.get("direction", Vector2i.RIGHT)
	range_cells = config.get("range", 5)
	step_time = config.get("step_time", 0.08)
	payload = config
	global_position = grid_manager.cell_to_world(current_cell)
	var anim: StringName = config.get("animation", StringName("arcane_missile_2"))
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim):
		sprite.play(anim)
	elif sprite.sprite_frames and sprite.sprite_frames.has_animation("arcane_missile_2"):
		sprite.play("arcane_missile_2")

func _process(delta: float) -> void:
	if grid_manager == null:
		return
	_step_acc += delta
	while _step_acc >= step_time:
		_step_acc -= step_time
		if not _advance_one_cell():
			return

func _advance_one_cell() -> bool:
	if traveled >= range_cells:
		emit_signal("finished")
		queue_free()
		return false
	var next_cell := current_cell + direction
	if not grid_manager.is_walkable(next_cell):
		emit_signal("finished")
		queue_free()
		return false
	current_cell = next_cell
	traveled += 1
	global_position = grid_manager.cell_to_world(current_cell)
	var occupant := grid_manager.get_actor_at(current_cell)
	if occupant != null and occupant != source:
		emit_signal("hit", current_cell, occupant, payload)
		queue_free()
		return false
	return true
