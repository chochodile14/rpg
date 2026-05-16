extends HSlider

@export var audio_bus_name: String

var audio_bus_id: int

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	# Initialise le slider à la valeur actuelle du bus au démarrage
	value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus_id))

func _on_sfx_control_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
