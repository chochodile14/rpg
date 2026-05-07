extends RigidBody2D

func _on_area_2d_body_entered(body: Node2D) -> void:
		get_tree().change_scene_to_file("res://battle.tscn")




func _physics_process(delta: float) -> void:
	pass








#const speed = 20

#@export var player : Node2D
#@onready var nav_agent :=$NavigationAgent2D as NavigationAgent2D


#func _physics_process(_delta: float) -> void:
	#var dir = to_local(nav_agent.get_next_path_position()).normalized()
	#velocity = dir * speed
	#move_and_slide()
#func make_path():
	#nav_agent.target_position = player.global_position


#func _on_timer_timeout() -> void:
	#make_path() 
