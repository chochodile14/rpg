extends PanelContainer
var item_id = ""
var description = ""
var price = ""
signal item_hovered(item_id)
signal item_unhovered()
# Called when the node enters the scene tree for the first time.
func setup(item_name, quantity):
	item_id = item_name
	$VBoxContainer/TextureRect.texture = Global.items[item_name]["icon"]
	$VBoxContainer/Label.text = str(quantity)


func _on_texture_rect_mouse_entered() -> void:
	emit_signal("item_hovered",item_id)


func _on_texture_rect_mouse_exited() -> void:
	emit_signal("item_unhovered")
