extends Control

var dragging = false
var drag_offset = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			dragging = true
			drag_offset = event.position
		else:
			dragging = false
	
	if event is InputEventMouseMotion and dragging:
		position += event.position - drag_offset