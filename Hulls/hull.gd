extends Node2D

var player: AudioStreamPlayer
var pd: AudioStreamPlaybackPD


func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)
	
	var stream = AudioStreamPD.new()
	player.stream = stream
	
	player.play()
	pd = player.get_stream_playback()
	
	pd.open_patch("D:/dirs/Code/pd/gd/sams.pd")
	
	pd.send_message("samplePath", "read", [ "-resize", "D:/dirs/sound/SampleBank/Spring 2025 Loops/001_PadyTexture_177.wav", "Left", "Right"])
	#pd.send_symbol("samplePath", "D:/dirs/sound/SampleBank/Spring 2025 Loops/001_PadyTexture_177.wav")
	
	pd.send_bang("start")
	pd.send_float("vol", 0.5)