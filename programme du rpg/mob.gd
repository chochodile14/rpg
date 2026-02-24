extends CharacterBody2D

var speed = 0.1
var player_chase = false
var player:player_beta = null

func _physics_process(delta: float) -> void:
	if player_chase:
		print(position, player.position)
		position += (global_position + player.global_position) *speed *delta 


func _on_area_2d_body_entered(body: Node2D) -> void:#quand le joueur est proche
	player = body
	player_chase=true
	


func _on_area_2d_body_exited(body: Node2D) -> void:#quand le jouer n'est pas proche
	player = null
	player_chase = false
	
