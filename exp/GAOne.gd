class_name GAOne
extends Node2D

var screenSize: Vector2
var totalPop: int = 100
var element: Array[Ind]=[]

func _ready() -> void:
	screenSize = get_viewport_rect().size
	initPop()
	pass 



func _process(_delta: float) -> void:
	queue_redraw()
	pass

func initPop():
	for i in totalPop:
		var el = preload("res://exp/ind.gd").new()
		
		var pos = Vector2(randf_range(0.0, screenSize.x-el.IRadius),randf_range(0.0, screenSize.y-el.IRadius))
		el.IPos=pos;
		
		var dna = randi_range(i,255)
		el.Idna = dna
		print("DNA: ", dna)
		
		var col = dna / 255.0
		el.IColor = Color(col, col, col, 1.0)
		print("Color: ", col)
		
		add_child(el)
		element.push_back(el)
		
