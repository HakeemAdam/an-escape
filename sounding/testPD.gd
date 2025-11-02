extends Node2D

var player : AudioStreamPlayer
var pd: AudioStreamPlaybackPD

@onready var btn := $Ui/VBoxContainer/Button
@onready var bpmSlider := $Ui/VBoxContainer/bpmSlider
@onready var bpmValLabel := $Ui/VBoxContainer/bpmValueLabel
@onready var ui := $Ui 
@onready var delayBtn := $Ui/VBoxContainer/DelayBtn
@onready var reverbBtn := $Ui/VBoxContainer/ReverbBtn
@onready var volSlider := $Ui/VBoxContainer/VolumeSlider
@onready var credit := $Credit
@onready var creditBtn :=$Button

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
var reverb_bus_idx: int = -1
var delay_bus_idx: int = -1	


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		for b in blocks:
			var localPos = b.to_local(event.position)
			if b.blockRect.has_point(localPos):
				b.isPlaying = !b.isPlaying
				b.blockColor = _calcBlockColor(b.global_position, b.isPlaying)
				
				# Send mute state to PD (1 = playing, 0 = muted)
				var muteValue = 1.0 if b.isPlaying else 0.0
				pd.send_float("mute" + str(b.stepNumber), muteValue)
				print("  [PD SEND] mute%d -> %.0f" % [b.stepNumber, muteValue])
				
				print("[RIGHT CLICK] Block %d isPlaying: %s" % [b.stepNumber, b.isPlaying])
				break
	if event is InputEventKey and event.keycode == KEY_M and event.is_pressed():
		ui.visible = !ui.visible
		
func _ready() -> void:
	print("=== INITIALIZING SEQUENCER ===")
	screensize = get_viewport_rect().size
	get_viewport().size_changed.connect(_on_viewport_resized)
	print("Screen size: ", screensize)
	
	player = AudioStreamPlayer.new()
	add_child(player)
	
	var stream = AudioStreamPD.new()
	player.stream = stream
	
	_setup_audio_buses()
	
	reverbBtn.toggled.connect(_on_reverb_toggled)
	delayBtn.toggled.connect(_on_delay_toggled)
	creditBtn.pressed.connect(_onCreditsClick)
	
	player.play()
	pd = player.get_stream_playback()
	
	pd.open_patch("E:/dirs2/gdprojects/an-escape/sounding/pds/laurie.pd")
	print("PD Patch loaded: laurie.pd")
	
	btn.pressed.connect(onStartPreesed)
	bpmSlider.value_changed.connect(onBpmChnaged)
	
	pd.send_float("bpm", bpmSlider.value)
	bpmValLabel.text = str(bpmSlider.value)
	print("[PD SEND] bpm -> %.2f" % bpmSlider.value)
	
	volSlider.value_changed.connect(_on_volume_changed)
	_on_volume_changed(volSlider.value)
	
	
	
	_spawnBlock()
	_updateAllBlockColors()
	
	credit.visible = false
	print("=== INITIALIZATION COMPLETE ===\n")


func _process(_delta: float) -> void:
	
	if blocks.size() > 0:
		var mixedColor = Color.BLACK
		for b in blocks:
			mixedColor += b.blockColor
		mixedColor = mixedColor / blocks.size()
		RenderingServer.set_default_clear_color(mixedColor)	

func onStartPreesed():
	print("[PD SEND] start -> BANG")
	pd.send_bang("start")

func onBpmChnaged(value: float):
	print("[PD SEND] bpm -> %.2f" % value)
	pd.send_float("bpm", value)
	bpmValLabel.text = str(value)
		
func _spawnBlock():
	print("\n--- Spawning %d blocks ---" % numBlocks)
	for b in numBlocks:
		_creaetBlock(b)

func _creaetBlock(index: int):
	var block = Block.new()
	block.stepNumber = index
	block.global_position = Vector2(randf_range(0.0, screensize.x - block.blockSize), randf_range(0.0, screensize.y - block.blockSize))
	var note = randi_range(60, 90)
	block.noteValue = note
	block.blockColor=_calcBlockColor(block.global_position, false)
	
	block.position_changed.connect(_onBlockPosChanged)
	block.isPlaying=true
	
	add_child(block)
	blocks.append(block)
	print("Block %d created at position: %s" % [index, block.global_position])
	_updatePdFromBlock(block)


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


func _updatePdFromBlock(block: Block):
	var idx := block.stepNumber
	
	var normX = clampf(block.global_position.x / screensize.x, 0.0, 1.0)
	var normY = clampf(block.global_position.y / screensize.y, 0.0, 1.0)
	
	print("\n[BLOCK %d UPDATE] Position: (%.1f, %.1f) | Normalized: (%.2f, %.2f)" % [idx, block.global_position.x, block.global_position.y, normX, normY])
	
	var steps = int(lerp(4.0, 12.0, normX))
	pd.send_float("steps" + str(idx), steps)
	print("  [PD SEND] steps%d -> %d" % [idx, steps])
	
	var hits = int(lerp(1.0, 6.0, normY))
	pd.send_float("hits" + str(idx), hits)
	print("  [PD SEND] hits%d -> %d" % [idx, hits])
	
	var diag = (normX + normY) / 2.0
	var rot = int(lerp(1.0, 6.0, diag))
	pd.send_float("rotation" + str(idx), rot)
	print("  [PD SEND] rotation%d -> %d" % [idx, rot])
	
	var atk_time = lerp(1.0, 300.0, normX)
	pd.send_float("env" + str(idx+1) + "_atk_time", atk_time)
	print("  [PD SEND] env%d_atk_time -> %.1f" % [idx+1, atk_time])
	
	var dcy_time = lerp(100.0, 400.0, normY)
	pd.send_float("env" + str(idx+1) + "_dcy_time", dcy_time)
	print("  [PD SEND] env%d_dcy_time -> %.1f" % [idx+1, dcy_time])
	
	var filterCutoff = lerp(500.0, 4000.0, diag)
	pd.send_float("filter" + str(idx+1) + "Cutoff", filterCutoff)
	print("  [PD SEND] filter%dCutoff -> %.1f" % [idx+1, filterCutoff])

func _onBlockPosChanged(block: Block):
	print("\n[POSITION CHANGED] Block %d dragged" % block.stepNumber)
	_updatePdFromBlock(block)
	block.blockColor = _calcBlockColor(block.global_position, block.isPlaying)
	
func _on_viewport_resized() -> void:
	screensize = get_viewport_rect().size
	print("Viewport resized to: %s" % screensize)
	_updateAllBlockColors()


func _setup_audio_buses():
	
	reverb_bus_idx = AudioServer.bus_count
	AudioServer.add_bus(reverb_bus_idx)
	AudioServer.set_bus_name(reverb_bus_idx, "Reverb")
	var reverb = AudioEffectReverb.new()
	reverb.room_size = 0.8
	reverb.damping = 0.5
	reverb.wet = 0.3
	AudioServer.add_bus_effect(reverb_bus_idx, reverb)
	AudioServer.set_bus_send(reverb_bus_idx, "Master")
	AudioServer.set_bus_mute(reverb_bus_idx, true)  # Start muted
	
	# Add delay bus
	delay_bus_idx = AudioServer.bus_count
	AudioServer.add_bus(delay_bus_idx)
	AudioServer.set_bus_name(delay_bus_idx, "Delay")
	var delay = AudioEffectDelay.new()
	delay.tap1_active = true
	delay.tap1_delay_ms = 300.0
	delay.tap1_level_db = -6.0  # Use tap1_level_db instead (in decibels)
	delay.tap1_pan = 0.2  # Pan slightly right
	delay.tap2_active = true
	delay.tap2_delay_ms = 400.0
	delay.tap2_level_db = -12.0
	delay.tap2_pan = -0.2  # Pan slightly left
	delay.feedback_active = true
	delay.feedback_delay_ms = 340.0
	delay.feedback_level_db = -12.0
	AudioServer.add_bus_effect(delay_bus_idx, delay)
	AudioServer.set_bus_send(delay_bus_idx, "Master")
	AudioServer.set_bus_mute(delay_bus_idx, true)  # Start muted
	
		# Add effects directly to Master bus
	AudioServer.add_bus_effect(0, reverb)  # 0 = Master
	AudioServer.add_bus_effect(0, delay)
	
	# Disable by default
	AudioServer.set_bus_effect_enabled(0, 0, false)  # Reverb off
	AudioServer.set_bus_effect_enabled(0, 1, false) 
	
	# Route audio through these buses
	player.bus = "Master"
	
	print("Audio buses created: Reverb, Delay")

func _on_reverb_toggled(toggled_on: bool):
	AudioServer.set_bus_effect_enabled(0, 0, toggled_on) 
	print("[REVERB] %s" % ("ON" if toggled_on else "OFF"))

func _on_delay_toggled(toggled_on: bool):
	AudioServer.set_bus_effect_enabled(0, 1, toggled_on)
	print("[DELAY] %s" % ("ON" if toggled_on else "OFF"))

func _on_volume_changed(value: float):
	
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	print("[VOLUME] %.0f%% (%.1f dB)" % [value * 100, db])

func _onCreditsClick():
	credit.visible = !credit.visible
