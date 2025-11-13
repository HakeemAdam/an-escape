class_name Ind
extends Node2D


var IColor: Color = Color.WHITE:
	set(value):
		IColor = value
		
var Idna: int = 25:
	set(value):
		Idna = value

var IPos: Vector2 = Vector2.ZERO:
	set(value):
		IPos=value

var IRadius: float = 20:
	set(value):
		IRadius = value

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass
	
func _draw() -> void:
	draw_circle(IPos, IRadius, IColor)
