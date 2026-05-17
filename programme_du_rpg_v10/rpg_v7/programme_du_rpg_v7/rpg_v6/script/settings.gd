extends Control

#@export var audio_bus_name : String

#var audio_bus_id

#func _ready() -> void:
#	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

#func _on_music_control_value_changed(value) -> void:
#	var db = linear_to_db(value)
#	AudioServer.set_bus_volume_db(audio_bus_id, value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://hub.tscn")
