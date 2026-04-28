extends CharacterBody2D
var speed = 80.0
var player_chase = false
var player: Node2D = null
func _physics_process(delta: float) -> void:
	if player_chase and player != null:
		print("Player pos:", player.global_position)
		print("Monster pos:", global_position)
		print("Diff:", player.global_position - global_position)
		print("Collision :", get_slide_collision_count())
		var target = player.global_position
		velocity = global_position.direction_to(target) * speed
	else:
			velocity = Vector2.ZERO
			move_and_slide()
func _on_area_2d_body_entered(body: Node2D) -> void:   
	print("Collision :", get_slide_collision_count()) 
	print("Quelque chose est entré dans la zone :", body.name)    
	if body.is_in_group("Player"):       
		print(" Joueur détecté !")        
		player = body        
		player_chase = true    
	else:        
		print(" Ce n'est pas le joueur")
		
func _on_area_2d_body_exited(body: Node2D) -> void:    
	print("Quelque chose est sorti :", body.name)    
	if body == player:        
		print("➡️ Joueur sorti de la zone")        
		player = null        
		player_chase = false
		print("Collision :", get_slide_collision_count())
