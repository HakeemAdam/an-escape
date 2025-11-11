extends Node2D


# init - create x amnt of things, give dna and traits, life time rate, mutation chnace
# selection - eval the fitn of all indiviual and build and maiting pool
# Reproduction - 
	# pick 2 parent - by probablity nd fitness
	# corssover - create a child by combining the dna of the two parents
	# mutation - modify the childs dna by probabiliyt
	# add new child to the new population 
# replace population and reselction - step 2

var randCharArray: Array[String] =[]
var resultString: Array[String] = ["C", "A", "T"]

func _ready() -> void:
	genCat()
	print(randCharArray)
	searchCat(randCharArray)
	

func searchCat(_search: Array[String]) -> void:
	for i in resultString.size():
		pass
	pass

func genCat() -> void:
	for i in 3:
		var ranChar :int = randomChar()
		var res : String = String.chr(ranChar)
		randCharArray.push_back(res)
		

func randomChar() -> int:
	return randi_range(0, 100)
	