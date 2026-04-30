class_name Player extends CharacterBody2D
@export var speed = 400 
var screen_size 
@export var target_scale =1
#func _ready() -> void:
	#screen_size = get_viewport_rect().size
func _ready():
	add_to_group("Player")
	print("Groupes du joueur :", get_groups())

func _physics_process(delta: float) -> void:
	var imput_dir = Vector2.ZERO
	if Input.is_action_pressed("mouvement_droit"):
		imput_dir.x += 1
	if Input.is_action_pressed("mouvement_gauche"):
		imput_dir.x -= 1
	if Input.is_action_pressed("mouvement_haut"):
		imput_dir.y -= 1
	if Input.is_action_pressed("mouvement_bas"):
		imput_dir.y += 1
	
	if imput_dir.length() > 0:
		imput_dir = imput_dir.normalized() * speed;
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	self.velocity = imput_dir
	move_and_slide()
	#position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = velocity.x < 0
		
func start_turn():
	target_scale = 1.1
	
func end_turn():
	target_scale=0.9
	
	
func is_player():
	pass
