extends Node
var _music_player: AudioStreamPlayer

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"  
	add_child(_music_player)

func play_menu_music(stream: AudioStream) -> void:
	if _music_player.playing and _music_player.stream and _music_player.stream.resource_path == stream.resource_path:
		return
	_music_player.stream = stream
	_music_player.play()

func stop_menu_music() -> void:
	_music_player.stop()
