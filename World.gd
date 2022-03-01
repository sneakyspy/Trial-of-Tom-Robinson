extends Node

onready var input = $Interface/cont/VBoxContainer/ScrollContainer/Input
onready var label = $Interface/Text_Display
var BUTTON = preload("res://Button.tscn")
var peeps_unlocked = ["Tom", "Bob", "Heck", "Court"]
var oldind = 0
var old = null
var x = 0
var can_advance = true

func parse_json_file(path):
	var FILE = File.new()
	FILE.open(path, FILE.READ)
	var text = FILE.get_as_text()
	var dict = parse_json(text)
	FILE.close()
	return dict

onready var Bob = parse_json_file("res://Files/Bob Ewell.tres")
onready var Burris = parse_json_file("res://Files/Burris.tres")
onready var Heck = parse_json_file("res://Files/Heck Tate.tres")
onready var Tom = parse_json_file("res://Files/Tom Robinson.tres")
onready var Mayella = parse_json_file("res://Files/Mayella.tres")
onready var Court = parse_json_file("res://Files/Court.tres")
onready var file = Tom
onready var index = 0
onready var current = file
var questions = 2
var people = ["You", "Tom", "Bob", "Heck", "Mayella",  "Burris", "Judge Taylor", "Court"]
var knows = []
var running = true

func _ready() -> void:
	label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") && can_advance && running:
		print(str(len(current)) + " , " + str(index))
		if index + 1 >= len(current):
			if old != null:
				current = old
				index = oldind
				if index + 1 > len(current):
					current = file
					index += 1
					label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])
				else:
					index += 1
					current = file
					label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])
				old = null
			elif index + 1 >= len(current) && old != null:
				current = file
				index += 1
				label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])
			else:
				new_file()
		elif "Action" in current[index + 1]:
			if current[index + 1]["Action"] in people:
				index += 1
				label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])
			elif current[index + 1]["Action"] == "end":
				label.set_text(current[index + 1]["Text"])
				running = false
				file = null
				current = null
			elif "Q" in current[index + 1]["Action"]:
				index += 1
				if old == null:
					old = current
					oldind = index
				current = current[index]["Text"]
				index = 0
				for x in range(0, len(current)):
					var button = BUTTON.instance()
					if "req" in current[x][0] && current[x][0]["Text"] in knows:
						button.set_text(current[x][0]["Text"][0]["Text"])
						var thisbutton = button.duplicate()
						input.add_child(thisbutton)
						thisbutton.connect("pressed", self, "pressed", [x])
					elif "req" in current[x][0] && not current[x][0]["Text"] in knows:
						continue
					elif "Action" in current[x][0]:
						button.set_text(current[x][0]["Text"])
						var thisbutton = button.duplicate()
						input.add_child(thisbutton)
						thisbutton.connect("pressed", self, "pressed", [x])
					else:
						break
				can_advance = false
			elif "Unlock" in current[index + 1]["Action"]:
				if not current[index + 1]["Text"] in peeps_unlocked:
					peeps_unlocked.append(current[index + 1]["Text"])
					label.set_text("You unlocked " + current[index]["Text"])
				index += 1
			elif "information" in current[index + 1]["Action"]:
				index += 1
				if not current[index]["Text"] in knows:
					knows.append(current[index]["Text"])
					label.set_text("You learned that " + current[index]["Text"])
		elif "req" in current[index + 1] && current[index + 1]["req"] in knows:
			old = current
			oldind = index + 1
			index = 0
			current = current[oldind]["Text"]
			label.set_text(current[index]["Text"])
		elif "req" in current[index + 1] && not current[index + 1]["req"] in knows:
			if index + 1 >= len(current):
				if current != old && old != null:
					current = old
					index = oldind + 1
					label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])
				else:
					current = file
					index += 1
					label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])
			else:
				for x in range(index + 1, len(current)):
					if "req" in current[x] && current[x]["req"] in knows:
						index += x - index
					else:
						index += 1
		else:
			print("Null input")

func pressed(y):
	if "req" in current[y][0]:
		current = current[y][0]["Text"]
		index = 0
		label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])
	elif "Action" in current[y][0]:
		current = current[y]
		index = 0
		label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])
	for n in input.get_children():
		n.queue_free()
	can_advance = true

func new_file():
	can_advance = false
	for x in peeps_unlocked:
		var button = BUTTON.instance()
		button.set_text(x)
		var thisbutton = button.duplicate()
		input.add_child(thisbutton)
		thisbutton.connect("pressed", self, "new_pressed", [get(x)])

func new_pressed(y):
	file = y
	current = file
	index = 0
	label.set_text("[" + current[index]["Action"] + "]" + " " + current[index]["Text"])
	for n in input.get_children():
		n.queue_free()
	can_advance = true
