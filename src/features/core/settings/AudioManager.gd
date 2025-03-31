extends Node

var _audio_listener : AudioListener2D
var _music_stream_player : AudioStreamPlayer

var _main_music_stream = preload("res://content/audio/music/Lawless_Cosmoss_OST.wav")

func _ready() -> void:
	_audio_listener = AudioListener2D.new()
	add_child(_audio_listener)
	_music_stream_player = AudioStreamPlayer.new()
	add_child(_music_stream_player)
	_music_stream_player.stream = _main_music_stream
	_music_stream_player.play()

func modify_master_volume(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(_music_stream_player.bus), linear_to_db(value))
