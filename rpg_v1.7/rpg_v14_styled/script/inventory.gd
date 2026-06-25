extends Node2D
@onready var inventory = $CanvasLayer
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func ShowInventory():
		$CanvasLayer.visible = true


func _on_close_pressed() -> void:
	var map = get_tree().current_scene
	if map.has_method("PauseMenu"):
		map.PauseMenu()
	$CanvasLayer.visible = false
