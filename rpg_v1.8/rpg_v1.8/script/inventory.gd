extends Node2D
 
@onready var canvas  = $CanvasLayer
@onready var tooltip = $CanvasLayer/inventaire/ToolTips
@onready var grid    = $CanvasLayer/inventaire/GridContainer
const InventorySlotScene = preload("res://inventory_case.tscn")
 
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	canvas.visible = false
	tooltip.visible = false
 
func _process(_delta: float) -> void:
	if not tooltip.visible:
		return
 
	# Vérifie si la souris est encore sur une case de l'inventaire
	var mouse = get_viewport().get_mouse_position()
	var souris_sur_une_case = false
	for slot in grid.get_children():
		var rect = Rect2(slot.global_position, slot.size)
		if rect.has_point(mouse):
			souris_sur_une_case = true
			break
 
	# Si la souris n'est plus sur aucune case, on cache le tooltip
	if not souris_sur_une_case:
		tooltip.visible = false
	else:
		# Le tooltip suit la souris avec un décalage bas-droite
		tooltip.position = mouse + Vector2(12, 20)
 
func ShowInventory():
	tooltip.visible = false
	canvas.visible = true
	for child in grid.get_children():
		child.queue_free()
	for item in Global.inventory:
		if Global.inventory[item] > 0:
			var slot = InventorySlotScene.instantiate()
			slot.item_hovered.connect(_on_item_hovered)
			grid.add_child(slot)
			slot.setup(item, Global.inventory[item])
 
func _on_close_pressed() -> void:
	tooltip.visible = false
	var map = get_tree().current_scene
	if map.has_method("PauseMenu"):
		map.PauseMenu()
	canvas.visible = false
 
func _on_item_hovered(item_id):
	var item = Global.items[item_id]
	$CanvasLayer/inventaire/ToolTips/orga/name.text        = item["name"]
	$CanvasLayer/inventaire/ToolTips/orga/description.text = item["description"]
	$CanvasLayer/inventaire/ToolTips/orga/price.text       = str(item["price"]) + " or"
	tooltip.visible = true
