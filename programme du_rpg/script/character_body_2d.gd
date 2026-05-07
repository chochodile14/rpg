extends CharacterBody2D
class_name Player 

@export var speed = 400 
@export var target_scale = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("Player")
	print("Groupes du joueur :", get_groups())
	# Repositionne le joueur si on revient d'un combat
	if Global.player_spawn_position != Vector2.ZERO:
		global_position = Global.player_spawn_position
		Global.player_spawn_position = Vector2.ZERO  # reset après usage

func _physics_process(_delta: float) -> void:
	var input_dir = Input.get_vector("mouvement_gauche","mouvement_droit", "mouvement_haut", "mouvement_bas").normalized() * speed
	
	if input_dir:
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.stop()
		
	velocity = input_dir
	move_and_slide()
	
	if velocity.x != 0:
		animated_sprite_2d.animation = "walk"
		animated_sprite_2d.flip_h = velocity.x < 0

func start_turn():
	target_scale = 1.1
	
func end_turn():
	target_scale = 0.9

func is_player():
	pass
