extends CharacterBody2D

var sprint_toggle = false
var state = "IDLE"
@export var speed = 400 

#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("Player")
	print("Groupes du joueur :", get_groups())
	# Repositionne le joueur si on revient d'un combat
	if Global.player_spawn_position != Vector2.ZERO:
		global_position = Global.player_spawn_position
		Global.player_spawn_position = Vector2.ZERO  # reset après usage

func _physics_process(_delta: float) -> void:
	var input_dir = Input.get_vector("mouvement_gauche","mouvement_droit", "mouvement_haut", "mouvement_bas")
	if Input.is_action_just_pressed("sprint toggle"):
		sprint_toggle =! sprint_toggle
	
	if input_dir == Vector2.ZERO:
		sprint_toggle = false
		state = "IDLE"
	else:
		if sprint_toggle:
			state = "RUN"
		else:
			state = "WALK"
	
	
	match state:
		"IDLE":
			
			$AnimatedSprite2D.play("idle")
		"WALK":
			speed = 400
			velocity = input_dir * speed
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = input_dir.x < 0
			move_and_slide()
		"RUN":
			$AnimatedSprite2D.play("run")
			speed = 600
			velocity = input_dir * speed
			$AnimatedSprite2D.flip_h = input_dir.x < 0
			move_and_slide()
