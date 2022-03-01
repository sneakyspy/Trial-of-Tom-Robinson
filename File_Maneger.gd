extends Node
onready var input = $Interface/cont/Input
onready var label = $Interface/cont/Text_Display
var BUTTON = preload("res://Button.tscn")
var oldin = 0
var old = 0
var x = 0

func parse_json_file(path):
	var file = File.new()
	file.open(path, file.READ)
	var text = file.get_as_text()
	var dict = parse_json(text)
	file.close()
	return dict

onready var Bob = parse_json_file("res://Files/Bob Ewell.tres")
onready var Burris = parse_json_file("res://Files/Burris.tres")
onready var Heck = parse_json_file("res://Files/Heck Tate.tres")
onready var Mayella = parse_json_file("res://Files/Mayella.tres")
onready var Tom = parse_json_file("res://Files/Tom Robinson.tres")
onready var file = Tom
onready var index = 0
onready var current = file
var unlocked = []

func _ready() -> void:
	label.set_text(current[index]["Text"])

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if index + 1 >= len(current):
			current = file
			index = old + x + 1
			if index + 1 > len(file):
				for y in [Tom, Bob, Heck]:
					var button = BUTTON.instance()
					button.set_text([Tom, Bob, Heck][x])
					var thisbutton = button.duplicate()
					input.add_child(thisbutton)
		elif typeof(current) == TYPE_DICTIONARY:
			current = file
			index = old + x
			if typeof(current[index]) == TYPE_DICTIONARY:
				index += 1
				label.set_text(current[index]["Text"])
			else:
				return
		elif typeof(current[index+1]) == TYPE_DICTIONARY:
			index += 1
			label.set_text(current[index]["Text"])
		elif typeof(current[index + 1]) == TYPE_ARRAY:
			old = index
			for x in range(index + 1, len(current)):
				if typeof(current[x]) == TYPE_ARRAY:
					if current[x][0]["Action"] == "req":
						if current[x][1]["Action"] == "Q" && current[x][0]["Text"] in unlocked:
							var button = BUTTON.instance()
							button.set_text(current[x][1]["Text"])
							var thisbutton = button.duplicate()
							input.add_child(thisbutton)
							thisbutton.connect("pressed", self, "pressed", [1])
							x += 1
						else:
							continue
					elif typeof(current[index + x]) == TYPE_ARRAY && current[index + x][0]["Action"] == "Q":
						var button = BUTTON.instance()
						button.set_text(current[index + x][0]["Text"])
						var thisbutton = button.duplicate()
						input.add_child(thisbutton)
						thisbutton.connect("pressed", self, "pressed", [0])
					elif typeof(current[index + 1]) == TYPE_ARRAY && index > len(current[index]):
						current = old
						index = oldin
						break 
				x += 1


func pressed(indx):
	for n in input.get_children():
		n.queue_free()
	if typeof(current) == TYPE_ARRAY:
		current = current[index]
		index = indx
		label.set_text(current[index])

func newfile():
	pass

func Q():
	pass
