extends AudioStreamPlayer

const battle_music = preload("res://music/music de battle/Dark Souls 3 Abyss Watchers Remix - All For One.mp3")

func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()

func play_music_battle():
	play_music_battle()
