extends GridActor
class_name ZombieActor

func consume_intention(actors: Array[GridActor]) -> void:
	intended_action = ActionType.NONE
	if is_dead:
		return
	var target := _find_mage(actors)
	if target == null:
		play_dir_animation("idle")
		return

	var direction := _direction_to_target_cardinal(target.cell)
	if direction != Vector2i.ZERO:
		facing = direction

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
	var target := _find_mage(actors)
	if target == null:
		return
	if manhattan_distance_to(target.cell) > base_attack_range:
		return
	_attack_timer = attack_cooldown
	queue_recovery()
	play_dir_animation("slash")
	target.take_damage(base_damage)

func _find_mage(actors: Array[GridActor]) -> GridActor:
	for actor in actors:
		if actor.is_dead:
			continue
		if actor.team == "player":
			return actor
	return null

func _direction_to_target_cardinal(target_cell: Vector2i) -> Vector2i:
	var delta := target_cell - cell
	if absi(delta.x) > absi(delta.y):
		return Vector2i(signi(delta.x), 0)
	if delta.y != 0:
		return Vector2i(0, signi(delta.y))
	if delta.x != 0:
		return Vector2i(signi(delta.x), 0)
	return Vector2i.ZERO
