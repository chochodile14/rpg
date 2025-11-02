extends CanvasLayer
signal start_game


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	start_game.emit()
	$start.hide()
	get_tree().change_scene_to_file("res://map.tscn")
