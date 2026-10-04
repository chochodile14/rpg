extends StaticBody2D
@export var target_scene: String = "res://boss_map.tscn"
@export var spawn_position: Vector2 = Vector2(274.0, -135.0)
var player_in_range = false
var state = "Idle"
var _last_state = ""
var _is_active = false

func _ready() -> void:
	$AnimatedSprite2D.visible = false

func _physics_process(delta: float) -> void:
	if state != _last_state:
		_last_state = state
		match state:
			"Idle":
				$AnimatedSprite2D.play("IDLE")
			"disparaition":
				$AnimatedSprite2D.play("disparaition")
			"spawn":
				$AnimatedSprite2D.play("spawn")
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interaction"):
		print("F appuyé — player_in_range = ", player_in_range)
	if player_in_range and Input.is_action_just_pressed("interaction"):
		Global.return_scene_path = get_tree().current_scene.scene_file_path
		Global.return_position = global_position + Vector2(0, 24)  
		Global.player_spawn_position = spawn_position
		get_tree().change_scene_to_file(target_scene)
		

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player") and not _is_active:
		player_in_range = true
		_is_active = true
		print("portail la ")
		$AnimatedSprite2D.visible = true
		state = "spawn"
		await get_tree().create_timer(0.8).timeout
		state = "Idle"

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and _is_active:
		player_in_range = false
		_is_active = false
		print("portail plus la ")
		state = "disparaition"
		await get_tree().create_timer(0.8).timeout
		$AnimatedSprite2D.visible = false
