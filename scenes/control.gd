extends Control

const AI_EXAMPLE:String = "In the dim glow of the candlelit chamber, Misery Chastain discovered a delicate paper clip, its metallic sheen a stark contrast against the aged parchment of Ian's heartfelt letter, a missive that spoke of undying love and whispered secrets. Nearby, an apple, polished to a crimson gleam, lay untouched on the windowsill, a symbol of forbidden temptation and the bittersweet choices that lay ahead. As Misery pondered her fate, her gaze fell upon a small pig ceramic figure, a cherished keepsake from Geoffrey, its presence a poignant reminder of innocence lost and the fragile bonds of friendship that tethered her heart to both men."

@onready var bg_0: Sprite2D = $"../bg0"
@onready var bg_1: Sprite2D = $"../bg1"

@onready var hide_time: Timer = $HideTime

@onready var button_1: Button = $Button1/Button
@onready var button_2: Button = $Button2/Button
@onready var button_3: Button = $Button3/Button

@onready var choice_1: PanelContainer = $Choice1
@onready var choice_2: PanelContainer = $Choice2
@onready var choice_3: PanelContainer = $Choice3

var options_positive:Array[String] = ['opt1-1', 'opt2-1', 'opt3-1']
var options_neutral:Array[String] = ['opt1-2', 'opt2-2', 'opt3-2']
var options_negative:Array[String] = ['opt1-3', 'opt2-3', 'opt3-3']
var selection1:String
var selection2:String
var selection3:String

var current_stage:int = 1

func _ready():
	button_1.grab_focus()
	button_1.button_up.connect(_button_pressed.bind(button_1))
	button_2.button_up.connect(_button_pressed.bind(button_2))
	button_3.button_up.connect(_button_pressed.bind(button_3))
	
	choice_1.get_child(2).button_up.connect(_stage_back.bind(choice_1))
	choice_2.get_child(2).button_up.connect(_stage_back.bind(choice_2))
	choice_3.get_child(2).button_up.connect(_stage_back.bind(choice_3))
	
	choice_1.visible = false
	choice_2.visible = false
	choice_3.visible = false
	
	Dialogic.timeline_ended.connect(exit_writing_stage)

func _process(delta:float) -> void:
	match current_stage:
		1:
			button_1.text = options_positive[0]
			button_2.text = options_neutral[0]
			button_3.text = options_negative[0]
		2:
			button_1.text = options_positive[1]
			button_2.text = options_neutral[1]
			button_3.text = options_negative[1]
			choice_1.visible = true
		3:
			button_1.text = options_positive[2]
			button_2.text = options_neutral[2]
			button_3.text = options_negative[2]
			choice_1.visible = true
			choice_2.visible = true
		4:
			choice_1.visible = true
			choice_2.visible = true
			choice_3.visible = true
			button_1.get_parent().visible = false
			button_2.get_parent().visible = false
			button_3.get_parent().visible = false
			print('execute script misery.py')
			Dialogic.VAR.AI_OUTPUT = AI_EXAMPLE
			Dialogic.start('ai_output')
			current_stage = -1 #disable process loop
			

func _button_pressed(button:Button):
	match current_stage:
		1:
			selection1 = button.text
			choice_1.get_child(0).text = selection1
			choice_1.get_child(1).play('unfold')
			button_1.grab_focus()
		2:
			selection2 = button.text
			choice_2.get_child(0).text = selection2
			choice_2.get_child(1).play('unfold')
			button_1.grab_focus()
		3:
			selection3 = button.text
			choice_3.get_child(0).text = selection3
			bg_0.visible = false
			bg_1.visible = true
			choice_3.get_child(1).play('unfold')
			button_1.grab_focus()
	current_stage += 1

func _stage_back(choice:PanelContainer):
	match choice.name:
		'Choice1':
			choice_2.get_child(1).play('fold')
			choice_1.get_child(1).play('fold')
			current_stage = 1
		'Choice2':
			choice_2.get_child(1).play('fold')
			current_stage = 2
		'Choice3':
			pass #can't go back once choice 3 is selected
	button_1.grab_focus()
	hide_time.start()

func _on_hide_time_timeout() -> void:
	match current_stage:
		1:
			choice_1.visible = false
			choice_2.visible = false
			choice_3.visible = false
		2: 
			choice_2.visible = false
			choice_3.visible = false
		3:
			pass 

func exit_writing_stage():
	get_tree().reload_current_scene()
