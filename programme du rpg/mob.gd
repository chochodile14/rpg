extends CharacterBody2D

var speed = 0.1
var player_chase = false
var player:player_beta = null

func _physics_process(delta: float) -> void:
	if player_chase and player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed * 100
		move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "player_beta": # ou mieux avec un groupe
		player = body
		player_chase = true
	


func _on_area_2d_body_exited(body: Node2D) -> void:#quand le jouer n'est pas proche
	player = null
	player_chase = false
	
