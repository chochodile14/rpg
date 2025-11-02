extends CharacterBody2D
@export var speed =400 

func process(delta):
	var velocity = Vector2.ZERO
	
	velocity.x += Input.get_axis("mouvement_gauche","mouvement_droit") 
	velocity.y += Input.get_axis("mouvement_haut","mouvement_bas")

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed;
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta 
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = velocity.x < 0
