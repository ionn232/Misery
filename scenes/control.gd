extends Control

@onready var bg_0: Sprite2D = $"../bg0"
@onready var bg_1: Sprite2D = $"../bg1"


@onready var button_1: Button = $Button1/Button
@onready var button_2: Button = $Button2/Button
@onready var button_3: Button = $Button3/Button

@onready var choice_1: PanelContainer = $Choice1
@onready var choice_2: PanelContainer = $Choice2
@onready var choice_3: PanelContainer = $Choice3

var options_1st_stage:Array[String] = ['opt1-1', 'opt1-2', 'opt1-3']
var options_2nd_stage:Array[String] = ['opt2-1', 'opt2-2', 'opt2-3']
var options_3rd_stage:Array[String] = ['opt3-1', 'opt3-2', 'opt3-3']
var selection1:String
var selection2:String
var selection3:String

var current_stage:int = 1

func _ready():
	button_1.grab_focus()
	button_1.button_up.connect(_button_pressed.bind(button_1))
	button_2.button_up.connect(_button_pressed.bind(button_2))
	button_3.button_up.connect(_button_pressed.bind(button_3))

func _process(delta:float) -> void:
	match current_stage:
		1:
			button_1.text = options_1st_stage[0]
			button_2.text = options_1st_stage[1]
			button_3.text = options_1st_stage[2]
			choice_1.visible = false
			choice_2.visible = false
			choice_3.visible = false
		2:
			button_1.text = options_2nd_stage[0]
			button_2.text = options_2nd_stage[1]
			button_3.text = options_2nd_stage[2]
			choice_1.visible = true
			choice_2.visible = false
			choice_3.visible = false
		3:
			button_1.text = options_3rd_stage[0]
			button_2.text = options_3rd_stage[1]
			button_3.text = options_3rd_stage[2]
			choice_1.visible = true
			choice_2.visible = true
			choice_3.visible = false
		4:
			choice_1.visible = true
			choice_2.visible = true
			choice_3.visible = true
			button_1.get_parent().visible = false
			button_2.get_parent().visible = false
			button_3.get_parent().visible = false

func _button_pressed(button):
	match current_stage:
		1:
			selection1 = button.text
			choice_1.get_child(0).text = selection1
			button_1.grab_focus()
		2:
			selection2 = button.text
			choice_2.get_child(0).text = selection2
			button_1.grab_focus()
		3:
			selection3 = button.text
			choice_3.get_child(0).text = selection3
			bg_0.visible = false
			bg_1.visible = true
			button_1.grab_focus()
		4:
			print('llamar IA y pasar a display de texto')
			pass
	current_stage += 1
