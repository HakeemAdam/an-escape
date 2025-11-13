class_name GAOne
extends Node2D

var screenSize: Vector2
var totalPop: int = 100:
	set(value):
		totalPop=value
		
var mutationRate: float = 0.1
var elements: Array[Ind]=[]
var matingPool: Array[Ind]=[]

var btn: Button
var canvas: CanvasLayer

func _ready() -> void:
	screenSize = get_viewport_rect().size
	canvas = CanvasLayer.new()
	canvas.layer = 100
		
	btn = Button.new()
	btn.global_position = Vector2(0, 200)
	btn.text = "reproduce"
	add_child(canvas)
	canvas.add_child(btn)
	
	btn.pressed.connect(onrepPressed)
	
	initPop()
	SelectMatingPool()
	print("mating pool Size:", matingPool.size())
	pass 



func _process(_delta: float) -> void:
	#for i in 10:
		#onrepPressed()
	queue_redraw()
	pass

func initPop() -> void:
	for i in totalPop:
		var el = addInd()
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
	if element > 0.25 :
		return 3
	elif element > 0.15:
		return 2
	else:
		return 1


func reproduce():
	var newGen: Array[Ind]=[]
	# error here 
	for i in totalPop:
		var ParentA = matingPool.pick_random()
		var ParentB = matingPool.pick_random()
		
		var childColor = lerp(ParentA.IColor, ParentB.IColor,1.0)
		var childDNA = lerp(ParentA.Idna, ParentB.Idna, 0.5)
		
		var newChild = addInd()
		newChild.Idna = childDNA
		newChild.IColor=childColor
		
		if (randf_range(0,1) < mutationRate ):
			newChild.IColor = Color.YELLOW_GREEN
			print("mutation")
		add_child(newChild)
		newGen.push_back(newChild)
		
	for el in elements:
		if el.IFitness ==1:
			remove_child(el)
			queue_free()
			
	elements= newGen
	totalPop=elements.size() 
			

func addInd() -> Ind:
	var el = preload("res://exp/ind.gd").new()
	var pos = Vector2(randf_range(0.0, screenSize.x-el.IRadius),randf_range(0.0, screenSize.y-el.IRadius))
	el.IPos=pos
		
	var dna = randi_range(0,255) / 255.0
	el.Idna = dna
	#print("DNA: ", dna)
		
	var col = dna 
	el.IColor = Color(col, col, col, 1.0)
	
	return el

func onrepPressed():
	reproduce()
	SelectMatingPool()
	print("Mating pool Size:", matingPool.size())
	print("Population Size:", totalPop)
	