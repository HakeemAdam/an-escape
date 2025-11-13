class_name GAOne
extends Node2D

var screenSize: Vector2
var totalPop: int = 100
var elements: Array[Ind]=[]
var matingPool: Array[Ind]=[]

func _ready() -> void:
	screenSize = get_viewport_rect().size
	initPop()
	SelectMatingPool()
	print("mating pool Size:", matingPool.size())
	
	
	pass 



func _process(_delta: float) -> void:

	queue_redraw()
	pass

func initPop() -> void:
	for i in totalPop:
		var el = preload("res://exp/ind.gd").new()
		
		var pos = Vector2(randf_range(0.0, screenSize.x-el.IRadius),randf_range(0.0, screenSize.y-el.IRadius))
		el.IPos=pos;
		
		var dna = randi_range(i,255) / 255.0
		el.Idna = dna
		print("DNA: ", dna)
		
		var col = dna 
		el.IColor = Color(col, col, col, 1.0)
		
		add_child(el)
		elements.push_back(el)
		
func SelectMatingPool() -> void:
	matingPool.clear()
	for i in elements:
		var fit = evalFitness(i.Idna)
		
		var prob = fit / 3.0
		if randf() < prob:
			matingPool.push_back(i)
	pass
	
func evalFitness(element: float) -> int:
	if element > 0.15 :
		return 3
	elif element > 0.25:
		return 2
	else:
		return 1
