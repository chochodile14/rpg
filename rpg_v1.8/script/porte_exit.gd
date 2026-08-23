extends StaticBody2D

@export var target_scene: String = "res://map.tscn"


var entered = false

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		print ("joueur entrer")
		entered = true
		$InteractionPrompt.show_prompt()

func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		entered = false
		$InteractionPrompt.hide_prompt()

func _process(delta: float) -> void:
	if entered and Input.is_action_just_pressed("interaction"):
		Global.player_spawn_position = Global.return_position
		get_tree().change_scene_to_file(Global.return_scene_path)
		print ("entrer dans la maison")
