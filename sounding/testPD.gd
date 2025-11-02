extends Node2D

var player : AudioStreamPlayer
var pd: AudioStreamPlaybackPD

@onready var btn := $Ui/VBoxContainer/Button
@onready var bpmSlider := $Ui/VBoxContainer/bpmSlider
@onready var bpmValLabel := $Ui/VBoxContainer/bpmValueLabel

var blocks: Array[Block]=[]
var screensize: Vector2
const BASE_COLOR = Color(0.3, 0.3, 0.3, 0.5) 
const ACTIVE_HIGHLIGHT = Color(1.0, 1.0, 1.0, 0.9)

var numBlocks: int = 4:
	set(value):
		numBlocks =value
		
const EFFECT_COLORS := {
	"delay": Color(0.0, 0.8, 1.0, 0.7),
	"reverb": Color(0.3, 0.2, 1.0, 0.7),
	"filter": Color(1.0, 0.8, 0.2, 0.7),
	"distortion": Color(1.0, 0.2, 0.4, 0.7)
	}

func _ready() -> void:
	screensize = get_viewport_rect().size
	player = AudioStreamPlayer.new()
	add_child(player)
	
	var stream = AudioStreamPD.new()
	player.stream = stream
	
	player.play()
	pd = player.get_stream_playback()
	
	pd.open_patch("E:/dirs2/gdprojects/an-escape/sounding/pds/laurie.pd")
	btn.pressed.connect(onStartPreesed)
	bpmSlider.value_changed.connect(onBpmChnaged)
	
	pd.send_float("bpm", bpmSlider.value)
	bpmValLabel.text = str(bpmSlider.value)
	_spawnBlock()
	

func onStartPreesed():
	pd.send_bang("start")

func onBpmChnaged(value: float):
		pd.send_float("bpm", value)
		bpmValLabel.text = str(value)
		
func _spawnBlock():
	for b in numBlocks:
		_creaetBlock(b)

func _creaetBlock(index: int):
	var block = Block.new()
	block.stepNumber = index
	block.global_position = Vector2(randf_range(0.0, screensize.x - block.blockSize), randf_range(0.0, screensize.y - block.blockSize))
	var note = randi_range(60, 90)
	block.noteValue = note
	block.blockColor=_calcBlockColor(block.global_position, false)
	add_child(block)
	blocks.append(block)


func _calcBlockColor(blockPos: Vector2, isActive: bool) ->Color:
	var finalColor = BASE_COLOR
	var normX := clampf(blockPos.x/screensize.x, 0.0, 1.0)
	var normY := clampf(blockPos.y/screensize.y, 0.0, 1.0)
	
	var colorBlend = Color.BLACK
	var totalWeight = 0.0
	
	if  normX > 0.05:
		colorBlend +=EFFECT_COLORS["delay"] * normX
		totalWeight += normX
	if normX > 0.05:
		colorBlend += EFFECT_COLORS["reverb"] *normX
		totalWeight += normX
	if  normY > 0.05:
		colorBlend += EFFECT_COLORS["filter"] * normY
		totalWeight += normY
	if  normY > 0.05:
		colorBlend+= EFFECT_COLORS["distortion"]*normY
		totalWeight += normY
		
	if totalWeight > 0.0:
		colorBlend = colorBlend/totalWeight
		var fxStrenght = clampf(totalWeight/2.0, 0.0, 1.0)
		finalColor = BASE_COLOR.lerp(colorBlend, fxStrenght)
		
	if isActive:
		finalColor = finalColor.lightened(0.3)
	return finalColor

func _updateAllBlockColors():
	for b in blocks:
		b.blockColor = _calcBlockColor(b.global_position, b.isPlaying)