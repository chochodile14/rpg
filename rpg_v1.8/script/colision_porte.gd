extends StaticBody2D

@export var target_scene: String = "res://maison.tscn"
@export var spawn_position: Vector2 = Vector2(88.0, 119.0)


var entered = false

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		entered = true
		$InteractionPrompt.show_prompt()

func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		entered = false
		$InteractionPrompt.hide_prompt()

func _process(delta: float) -> void:
	if entered and Input.is_action_just_pressed("interaction"):
		Global.return_scene_path = get_tree().current_scene.scene_file_path
		Global.return_position = global_position + Vector2(0, 24)  # léger décalage porte

		Global.player_spawn_position = spawn_position
		get_tree().change_scene_to_file(target_scene)
