extends Node
class_name GridManager

@export var grid_size: Vector2i = Vector2i(20, 12)
@export var cell_size: int = 64

var occupant_map: Dictionary = {}
var _reservation_map: Dictionary = {}

func begin_tick() -> void:
	_reservation_map.clear()

func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2((cell.x + 0.5) * cell_size, (cell.y + 0.5) * cell_size)

func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / cell_size), floori(pos.y / cell_size))

func is_walkable(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y

func is_occupied(cell: Vector2i) -> bool:
	return occupant_map.has(cell)

func get_actor_at(cell: Vector2i) -> Node:
	return occupant_map.get(cell, null)

func add_actor(actor: Node, cell: Vector2i) -> bool:
	if not is_walkable(cell) or is_occupied(cell):
		return false
	occupant_map[cell] = actor
	if actor.has_method("set_cell_from_grid"):
		actor.set_cell_from_grid(cell)
	return true

func remove_actor(actor: Node) -> void:
	for key: Vector2i in occupant_map.keys():
		if occupant_map[key] == actor:
			occupant_map.erase(key)
			return

func try_move(actor: Node, to_cell: Vector2i) -> bool:
	if not is_walkable(to_cell) or is_occupied(to_cell):
		return false
	var from_cell := _find_actor_cell(actor)
	if from_cell == null:
		return false
	occupant_map.erase(from_cell)
	occupant_map[to_cell] = actor
	if actor.has_method("set_cell_from_grid"):
		actor.set_cell_from_grid(to_cell)
	return true

func reserve_move(actor: Node, to_cell: Vector2i) -> bool:
	if not is_walkable(to_cell) or is_occupied(to_cell):
		return false
	if _reservation_map.has(to_cell):
		return false
	_reservation_map[to_cell] = actor
	return true

func commit_reserved_moves() -> void:
	for to_cell: Vector2i in _reservation_map.keys():
		var actor: Node = _reservation_map[to_cell]
		var from_cell := _find_actor_cell(actor)
		if from_cell == null:
			continue
		if occupant_map.has(to_cell):
			continue
		occupant_map.erase(from_cell)
		occupant_map[to_cell] = actor
		if actor.has_method("set_cell_from_grid"):
			actor.set_cell_from_grid(to_cell)
	_reservation_map.clear()

func _find_actor_cell(actor: Node) -> Variant:
	for key: Vector2i in occupant_map.keys():
		if occupant_map[key] == actor:
			return key
	return null
