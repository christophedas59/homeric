extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func play_once(animation_name: StringName = &"forebolt_zone") -> void:
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		sprite.play(animation_name)
	elif sprite.sprite_frames and sprite.sprite_frames.has_animation("forebolt_zone"):
		sprite.play("forebolt_zone")
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	queue_free()
