extends Node2D

var player : AudioStreamPlayer
var pd: AudioStreamPlaybackPD

@onready var btn := $Ui/VBoxContainer/Button
@onready var bpmSlider := $Ui/VBoxContainer/bpmSlider
@onready var bpmValLabel := $Ui/VBoxContainer/bpmValueLabel

func _ready() -> void:
	
	player = AudioStreamPlayer.new()
	add_child(player)
	
	var stream = AudioStreamPD.new()
	player.stream = stream
	
	player.play()
	pd = player.get_stream_playback()
	
	pd.open_patch("E:/dirs2/gdprojects/an-escape/sounding/pds/example.pd")
	btn.pressed.connect(onStartPreesed)
	bpmSlider.value_changed.connect(onBpmChnaged)
	
	pd.send_float("bpm", bpmSlider.value)
	bpmValLabel.text = str(bpmSlider.value)
	#pd.send_bang("start")

func onStartPreesed():
	pd.send_bang("start")

func onBpmChnaged(value: float):
		pd.send_float("bpm", value)
		bpmValLabel.text = str(value)
