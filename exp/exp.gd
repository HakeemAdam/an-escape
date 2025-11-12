extends Node2D


# init - create x amnt of things, give dna and traits, life time rate, mutation chnace
# selection - eval the fitn of all indiviual and build and maiting pool
# Reproduction - 
	# pick 2 parent - by probablity nd fitness
	# corssover - create a child by combining the dna of the two parents
	# mutation - modify the childs dna by probabiliyt
	# add new child to the new population 
# replace population and reselction - step 2


var resultString: Array[String] = ["C", "A", "T"]
var attempts: int =0
const MaxAttempts: int = 10000

func _ready() -> void:
	genCat()
	searchCat()
	

func searchCat() -> void:
	while attempts < MaxAttempts:
		attempts += 1
		var randCharArray: Array[String] = genCat()
		
		if randCharArray[0] == "C" and randCharArray[1] == "A" and randCharArray[2] == "T":
			print("Found cat after ", attempts, " Attempts!")
			print(randCharArray)
			break
		if attempts % 1000 == 0:
			print("Attempts ", attempts, ": ", randCharArray)
		if attempts >=MaxAttempts:
			print("Gave up after ", MaxAttempts, " attempts")

func genCat() -> Array[String]:
	var chars: Array[String] =[]
	for i in 3:
		var ranChar :int = randi_range(65, 90)
		var res : String = String.chr(ranChar)
		chars.push_back(res)
	return chars
		

func randomChar() -> int:
	return randi_range(65, 122)
	