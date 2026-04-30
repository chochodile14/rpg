extends Button



func _ready() -> void:
	pass
	

func _on_button_pressed() -> void:
	$Button.hide()
	get_tree().change_scene_to_file("res://map.tscn")

func _process(delta: float) -> void:
	pass
