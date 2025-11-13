class_name Ind
extends Node2D


var IColor: Color = Color.WHITE:
	set(value):
		IColor = value
		
var Idna: int = 25:
	set(value):
		Idna = value

var IFitness: int = 0:
	set(value):
		IFitness = value
		
var IPos: Vector2 = Vector2.ZERO:
	set(value):
		IPos=value

var IRadius: float = 20:
	set(value):
		IRadius = value

func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	queue_redraw()
	pass
	
func _draw() -> void:
	draw_circle(IPos, IRadius, IColor)
