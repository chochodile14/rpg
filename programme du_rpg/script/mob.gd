extends CharacterBody2D


func _on_rigid_body_2d_body_entered(body: Player) -> void:
	print("1")
	# Sauvegarde la position du monstre pour le retour sur la map
	Global.battle_mob_position = global_position
	get_tree().change_scene_to_file("res://battle.tscn")



const speed = 20

@export var player : Node2D
@onready var nav_agent :=$NavigationAgent2D as NavigationAgent2D


func _physics_process(_delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()
	

func make_path():
	nav_agent.target_position = player.global_position


func _on_timer_timeout() -> void:
	make_path() 
