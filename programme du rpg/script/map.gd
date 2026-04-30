extends Node2D



func _ready() -> void:
	pass

func new_game():
	$character_body_2d.start($Marker2D.position)
	$character_body_2d.show()
	$start.hide()

func _process(delta: float) -> void:
	pass
