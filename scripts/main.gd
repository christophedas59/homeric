extends Node2D

const TICK_INTERVAL: float = 0.1

const WIZARD_SCENE := preload("res://scenes/units/Wizard.tscn")
const ZOMBIE_SCENE := preload("res://scenes/units/Zombie.tscn")
const PROJECTILE_SCENE := preload("res://scenes/fx/Projectile.tscn")
const EXPLOSION_SCENE := preload("res://scenes/fx/ExplosionZone.tscn")

@onready var grid_manager: GridManager = $GridManager
@onready var units_root: Node2D = $Units
@onready var fx_root: Node2D = $FX

var actors: Array[GridActor] = []
var _tick_accumulator: float = 0.0
var _wizard: WizardActor

func _ready() -> void:
	_spawn_units()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast_firebolt") and _wizard != null and not _wizard.is_dead:
		_wizard.request_firebolt()

func _process(delta: float) -> void:
	_tick_accumulator += delta
	while _tick_accumulator >= TICK_INTERVAL:
		_tick_accumulator -= TICK_INTERVAL
		_run_tick(TICK_INTERVAL)

func _spawn_units() -> void:
	var wizard := WIZARD_SCENE.instantiate() as WizardActor
	units_root.add_child(wizard)
	wizard.initialize(grid_manager, Vector2i(3, 6))
	grid_manager.add_actor(wizard, wizard.cell)
	wizard.request_projectile.connect(_on_projectile_requested)
	actors.append(wizard)
	_wizard = wizard

	var zombie := ZOMBIE_SCENE.instantiate() as ZombieActor
	units_root.add_child(zombie)
	zombie.initialize(grid_manager, Vector2i(14, 6))
	grid_manager.add_actor(zombie, zombie.cell)
	actors.append(zombie)

func _run_tick(delta: float) -> void:
	grid_manager.begin_tick()
	for actor in actors:
		if not actor.is_dead:
			actor.update_timers(delta)

	for actor in actors:
		if actor.is_dead or actor.is_hard_locked():
			continue
		if actor is WizardActor:
			(actor as WizardActor).consume_intention(actors)
		elif actor is ZombieActor:
			(actor as ZombieActor).consume_intention(actors)

	for actor in actors:
		if actor.is_dead or actor.intended_action != GridActor.ActionType.MOVE:
			continue
		if grid_manager.reserve_move(actor, actor.intended_move_cell):
			actor.trigger_move_cooldown()
			actor.play_dir_animation("walk")
	grid_manager.commit_reserved_moves()

	for actor in actors:
		if actor.is_dead:
			continue
		match actor.intended_action:
			GridActor.ActionType.ATTACK:
				if actor is WizardActor:
					(actor as WizardActor).resolve_attack(actors)
				elif actor is ZombieActor:
					(actor as ZombieActor).resolve_attack(actors)
			GridActor.ActionType.CAST:
				if actor is WizardActor:
					(actor as WizardActor).resolve_cast()
			_:
				if actor.intended_action != GridActor.ActionType.MOVE:
					actor.play_dir_animation("idle")
		actor.intended_action = GridActor.ActionType.NONE

func _on_projectile_requested(config: Dictionary) -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as GridProjectile
	fx_root.add_child(projectile)
	projectile.setup(grid_manager, config)
	projectile.hit.connect(_on_projectile_hit)

func _on_projectile_hit(cell: Vector2i, occupant: GridActor, payload: Dictionary) -> void:
	occupant.take_damage(payload.get("damage", 1))
	if payload.get("explosion", false):
		_apply_firebolt_aoe(cell, payload)

func _apply_firebolt_aoe(center: Vector2i, payload: Dictionary) -> void:
	var damage: int = payload.get("damage", 1)
	var cells := [center, center + Vector2i.UP, center + Vector2i.DOWN, center + Vector2i.LEFT, center + Vector2i.RIGHT]
	for c in cells:
		if not grid_manager.is_walkable(c):
			continue
		var fx := EXPLOSION_SCENE.instantiate()
		fx_root.add_child(fx)
		fx.global_position = grid_manager.cell_to_world(c)
		fx.play_once(&"forebolt_zone")
		var actor := grid_manager.get_actor_at(c)
		if actor != null:
			(actor as GridActor).take_damage(damage)
