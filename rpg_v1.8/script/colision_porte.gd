extends StaticBody2D
var entered = false

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		print ("joueur entrer")
		entered = true
		
func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		print ("joueur sort")
		entered = false

func _process(delta: float) -> void:
	if entered and Input.is_action_just_pressed("interaction") :
		print ("entrer dans la maison")
