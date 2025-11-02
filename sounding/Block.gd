class_name Block
extends Node2D

signal  position_changed(block: Block)

var sprite:Sprite2D
var spriteTexture: CompressedTexture2D = preload("res://textures/Sp1.png"):
	set(value):
		spriteTexture=value
		if sprite:
			sprite.texture = spriteTexture
			sprite.scale = Vector2(blockSize/ sprite.texture.get_size().x, blockSize/ sprite.texture.get_size().y)

var label: Label			
var blockSize: float = 50
			
var blockRect: Rect2
var blockColor: Color = Color.GREEN:
	set(value):
		blockColor =value
		if sprite:
			sprite.modulate = blockColor
var isDragging: bool = false
var isPlaying: bool = false
var dragOffset:Vector2 = Vector2.ZERO

var noteValue: float = 60.0:
	set(value):
		noteValue =value
		
var noteVelocity: float = 0.5:
	set(value):
		noteVelocity=value

var stepNumber: int = 0:
	set(value):
		stepNumber = value
		if label:
			label.text = str(stepNumber)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var localRect = Rect2(Vector2.ZERO, Vector2(blockSize, blockSize))
			if localRect.has_point(to_local(event.position)):
				isDragging= true
				dragOffset = event.position - global_position
				get_viewport().set_input_as_handled()
		elif event.is_released():
			if isDragging:
				isDragging =false
				get_viewport().set_input_as_handled()
	
	if event is InputEventMouseMotion and isDragging:
		_moveBlock(event.position-dragOffset)
		get_viewport().set_input_as_handled()
				

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = spriteTexture
	sprite.scale = Vector2(blockSize/ sprite.texture.get_size().x, blockSize/ sprite.texture.get_size().y)
	sprite.centered=false
	sprite.position = Vector2.ZERO
	add_child(sprite)
	
	label = Label.new()
	label.position = Vector2(10,10)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	label.text = str(stepNumber)
	add_child(label)
	
	blockRect = Rect2(Vector2.ZERO,Vector2(blockSize, blockSize))

func _process(_delta: float) -> void:
	queue_redraw()


func _moveBlock(_position: Vector2):
	var currentScreenSize: Vector2 = get_viewport_rect().size
	global_position = _position
	var minNote = 48
	var maxNote= 84
	
	noteVelocity = clamp(0.3 + (_position.x / currentScreenSize.x) * 0.6, 0.3, 0.9)
	noteValue = minNote + (_position.y / currentScreenSize.y) * (maxNote - minNote)
	position_changed.emit(self)

func getNormalisedPosition()-> Vector2:
	var screenSize = get_viewport_rect().size
	return Vector2(global_position.x / screenSize.x, global_position.y /screenSize.y)