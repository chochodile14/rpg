extends Node2D
@onready var inventory = $CanvasLayer
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	inventory.visible = false

func ShowInventory():
		$CanvasLayer.visible = true
		for items in Global.inventory:
			var label = Label.new()
			if Global.inventory[items] > 0:
				label.text = items
				$CanvasLayer/inventaire/VBoxContainer.add_child(label)
			

func _on_close_pressed() -> void:
	var map = get_tree().current_scene
	if map.has_method("PauseMenu"):
		map.PauseMenu()
	$CanvasLayer.visible = false
