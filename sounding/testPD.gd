extends Node2D

var player : AudioStreamPlayer
var pd: AudioStreamPlaybackPD

func _ready() -> void:
	
	player = AudioStreamPlayer.new()
	add_child(player)
	
	var stream = AudioStreamPD.new()
	player.stream = stream
	
	player.play()
	pd = player.get_stream_playback()
	
	pd.open_patch("E:/dirs2/gdprojects/an-escape/sounding/example.pd")
	
