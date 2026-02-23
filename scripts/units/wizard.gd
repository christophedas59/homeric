extends GridActor
class_name WizardActor

@export var firebolt_cooldown: float = 2.5
@export var firebolt_damage: int = 2
@export var firebolt_range: int = 5
@export var firebolt_projectile_step_time: float = 0.06

var _firebolt_timer: float = 0.0
var _firebolt_requested: bool = false

func update_timers(delta: float) -> void:
	super.update_timers(delta)
	_firebolt_timer = maxf(0.0, _firebolt_timer - delta)

func request_firebolt() -> void:
	_firebolt_requested = true

func consume_intention(actors: Array[GridActor]) -> void:
	intended_action = ActionType.NONE
	if is_dead:
		return
	var target := _find_nearest_enemy(actors)
	if target == null:
		play_dir_animation("idle")
		return

	var direction := _direction_to_target_cardinal(target.cell)
	if direction != Vector2i.ZERO:
		facing = direction

	if _firebolt_requested and _firebolt_timer <= 0.0 and not is_hard_locked():
		intended_action = ActionType.CAST
		_firebolt_requested = false
		return
	_firebolt_requested = false

	var dist := manhattan_distance_to(target.cell)
	if dist <= base_attack_range and can_attack():
		intended_action = ActionType.ATTACK
		return

	if can_move():
		var move_cell := choose_greedy_step(target.cell)
		if move_cell != cell:
			intended_action = ActionType.MOVE
			intended_move_cell = move_cell
			return
	play_dir_animation("idle")

func resolve_attack(actors: Array[GridActor]) -> void:
	var target := _find_nearest_enemy(actors)
	if target == null:
		return
	_attack_timer = attack_cooldown
	queue_recovery()
	play_dir_animation("cast_base")
	emit_signal("request_projectile", {
		"source": self,
		"start_cell": cell,
		"direction": facing,
		"range": base_attack_range,
		"step_time": base_projectile_step_time,
		"animation": base_projectile_animation,
		"damage": base_damage,
		"explosion": false
	})

func resolve_cast() -> void:
	if _firebolt_timer > 0.0:
		return
	_firebolt_timer = firebolt_cooldown
	set_cast_lock()
	queue_recovery()
	play_dir_animation("cast_action")
	emit_signal("request_projectile", {
		"source": self,
		"start_cell": cell,
		"direction": facing,
		"range": firebolt_range,
		"step_time": firebolt_projectile_step_time,
		"animation": StringName("firebolt"),
		"damage": firebolt_damage,
		"explosion": true
	})

func _find_nearest_enemy(actors: Array[GridActor]) -> GridActor:
	var best: GridActor = null
	var best_dist := 1_000_000
	for actor in actors:
		if actor == self or actor.is_dead or actor.team == team:
			continue
		var dist := manhattan_distance_to(actor.cell)
		if dist < best_dist:
			best = actor
			best_dist = dist
	return best

func _direction_to_target_cardinal(target_cell: Vector2i) -> Vector2i:
	var delta := target_cell - cell
	if absi(delta.x) > absi(delta.y):
		return Vector2i(signi(delta.x), 0)
	if delta.y != 0:
		return Vector2i(0, signi(delta.y))
	if delta.x != 0:
		return Vector2i(signi(delta.x), 0)
	return Vector2i.ZERO
