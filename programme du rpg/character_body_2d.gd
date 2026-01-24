extends CharacterBody2D
@export var speed = 400 
var screen_size 
func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("mouvement_droit"):
		velocity.x += 1
	if Input.is_action_pressed("mouvement_gauche"):
		velocity.x -= 1
	if Input.is_action_pressed("mouvement_haut"):
		velocity.y -= 1
	if Input.is_action_pressed("mouvement_bas"):
		velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed;
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = velocity.x < 0
