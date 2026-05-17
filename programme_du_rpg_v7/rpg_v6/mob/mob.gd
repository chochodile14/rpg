extends RigidBody2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	Global.battle_mob_position = global_position
	Global.player_spawn_position = position + (body.position - position).normalized() * 100
	# Redirige vers le combat tutoriel ou le combat normal
	if Global.is_tutorial:
		get_tree().change_scene_to_file("res://tutorial/tutorial_battle.tscn")
	else:
		get_tree().change_scene_to_file("res://battle.tscn")

func _physics_process(_delta: float) -> void:
	pass
