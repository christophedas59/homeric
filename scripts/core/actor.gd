extends Node2D
class_name GridActor

signal request_projectile(data: Dictionary)

enum ActionType { NONE, MOVE, ATTACK, CAST }

const DIRS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

@export var team: String = "neutral"
@export var max_hp: int = 10
@export var move_interval: float = 0.3
@export var attack_cooldown: float = 0.8
@export var cast_windup: float = 0.35
@export var recovery_time: float = 0.2
@export var base_attack_range: int = 1
@export var base_damage: int = 1
@export var base_projectile_animation: StringName = &""
@export var base_projectile_step_time: float = 0.08
@export var interpolation_speed: float = 12.0

var hp: int
var cell: Vector2i = Vector2i.ZERO
var facing: Vector2i = Vector2i.DOWN
var grid_manager: GridManager
var is_dead: bool = false

var _move_timer: float = 0.0
var _attack_timer: float = 0.0
var _cast_timer: float = 0.0
var _recovery_timer: float = 0.0

var intended_action: ActionType = ActionType.NONE
var intended_move_cell: Vector2i = Vector2i.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	hp = max_hp

func _process(delta: float) -> void:
	if grid_manager == null:
		return
	var target_position := grid_manager.cell_to_world(cell)
	global_position = global_position.lerp(target_position, clampf(interpolation_speed * delta, 0.0, 1.0))

func initialize(manager: GridManager, start_cell: Vector2i) -> void:
	grid_manager = manager
	cell = start_cell
	global_position = grid_manager.cell_to_world(cell)
	play_dir_animation("idle")

func set_cell_from_grid(new_cell: Vector2i) -> void:
	var delta := new_cell - cell
	if delta != Vector2i.ZERO:
		facing = delta
	cell = new_cell

func update_timers(delta: float) -> void:
	_move_timer = maxf(0.0, _move_timer - delta)
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_cast_timer = maxf(0.0, _cast_timer - delta)
	_recovery_timer = maxf(0.0, _recovery_timer - delta)

func is_hard_locked() -> bool:
	return _cast_timer > 0.0 or _recovery_timer > 0.0

func can_move() -> bool:
	return _move_timer <= 0.0 and not is_hard_locked()

func can_attack() -> bool:
	return _attack_timer <= 0.0 and not is_hard_locked()

func trigger_move_cooldown() -> void:
	_move_timer = move_interval

func queue_recovery() -> void:
	_recovery_timer = recovery_time

func set_cast_lock() -> void:
	_cast_timer = cast_windup

func take_damage(amount: int) -> void:
	if is_dead:
		return
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	is_dead = true
	play_animation_safe("death")
	if grid_manager:
		grid_manager.remove_actor(self)

func manhattan_distance_to(other_cell: Vector2i) -> int:
	return absi(cell.x - other_cell.x) + absi(cell.y - other_cell.y)

func choose_greedy_step(target_cell: Vector2i) -> Vector2i:
	var options: Array[Vector2i] = []
	for dir in DIRS:
		options.append(cell + dir)
	options.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return _candidate_score(a, target_cell) < _candidate_score(b, target_cell)
	)
	for candidate in options:
		if grid_manager.is_walkable(candidate) and not grid_manager.is_occupied(candidate):
			return candidate
	return cell

func _candidate_score(candidate: Vector2i, target_cell: Vector2i) -> int:
	var base := absi(candidate.x - target_cell.x) + absi(candidate.y - target_cell.y)
	if not grid_manager.is_walkable(candidate):
		return base + 1000
	if grid_manager.is_occupied(candidate):
		return base + 100
	return base

func play_dir_animation(prefix: String) -> void:
	var direction := _dir_name_from_facing()
	play_animation_safe("%s_%s" % [prefix, direction])

func play_animation_safe(anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
		return
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("idle_down"):
		sprite.play("idle_down")

func _dir_name_from_facing() -> String:
	if facing == Vector2i.UP:
		return "up"
	if facing == Vector2i.LEFT:
		return "left"
	if facing == Vector2i.RIGHT:
		return "right"
	return "down"
