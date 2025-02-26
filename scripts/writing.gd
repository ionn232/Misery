class_name Writing
extends Node2D

const AI_EXAMPLE:String = "In the dim glow of the candlelit chamber, Misery Chastain discovered a delicate paper clip, its metallic sheen a stark contrast against the aged parchment of Ian's heartfelt letter, a missive that spoke of undying love and whispered secrets. Nearby, an apple, polished to a crimson gleam, lay untouched on the windowsill, a symbol of forbidden temptation and the bittersweet choices that lay ahead. As Misery pondered her fate, her gaze fell upon a small pig ceramic figure, a cherished keepsake from Geoffrey, its presence a poignant reminder of innocence lost and the fragile bonds of friendship that tethered her heart to both men."

const SELECTION_WEIGHT:float = 0.75

@onready var bg_0: Sprite2D = $"bg0"
@onready var bg_1: Sprite2D = $"bg1"

@onready var hide_time: Timer = $HideTime

@onready var button_1: Button = $Control/Button1/Button
@onready var button_2: Button = $Control/Button2/Button
@onready var button_3: Button = $Control/Button3/Button

@onready var choice_1: PanelContainer = $Control/Choice1
@onready var choice_2: PanelContainer = $Control/Choice2
@onready var choice_3: PanelContainer = $Control/Choice3

var options_positive:Array[String] = ['opt1-1', 'opt2-1', 'opt3-1']
var options_neutral:Array[String] = ['opt1-2', 'opt2-2', 'opt3-2']
var options_negative:Array[String] = ['opt1-3', 'opt2-3', 'opt3-3']
var selection1:String
var selection2:String
var selection3:String

var current_stage:int = 1

var phase_index:int

@onready var random_seed:int = randi_range(1,3)

signal phase_concluded

func load_scene(index: int):
	match index:
		0: #test writing stage
			pass
		1: #first writing stage
			options_positive = ['Hand clock', 'Penguin', 'Farm']
			options_neutral = ['Bowtie', 'Camel', 'Cabin']
			options_negative = ['Umbrella', 'Giraffe', 'Skyscraper']
		2: #second writing stage
			options_positive = ['Pig', 'Christian', 'Sea star']
			options_neutral = ['Dog', 'Lucius', 'Sardine']
			options_negative = ['Cat', 'Jesus', 'Seagull']
	phase_index = index

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
			random_buttons(current_stage)
		2:
			random_buttons(current_stage)
			choice_1.visible = true
		3:
			random_buttons(current_stage)
			choice_1.visible = true
			choice_2.visible = true
		4:
			choice_1.visible = true
			choice_2.visible = true
			choice_3.visible = true
			button_1.get_parent().visible = false
			button_2.get_parent().visible = false
			button_3.get_parent().visible = false
			register_choices()
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
			reroll_seed()
		2:
			selection2 = button.text
			choice_2.get_child(0).text = selection2
			choice_2.get_child(1).play('unfold')
			button_1.grab_focus()
			reroll_seed()
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
	reroll_seed()

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
	phase_concluded.emit()

func register_choices():
	evaluate_selection(selection1)
	evaluate_selection(selection2)
	evaluate_selection(selection3)

func reroll_seed():
	random_seed = randi_range(1,3)

func random_buttons(stage:int):
	match random_seed:
		1:
			button_1.text = options_positive[stage-1]
			button_2.text = options_neutral[stage-1]
			button_3.text = options_negative[stage-1]
		2:
			button_2.text = options_positive[stage-1]
			button_1.text = options_neutral[stage-1]
			button_3.text = options_negative[stage-1]
		3:
			button_3.text = options_positive[stage-1]
			button_2.text = options_neutral[stage-1]
			button_1.text = options_negative[stage-1]

func evaluate_selection(selection:String):
	if (selection in options_positive): #positive
		Dialogic.VAR.ANNIE_MOOD += SELECTION_WEIGHT
	elif(selection in options_negative): #negative
		Dialogic.VAR.ANNIE_MOOD -= SELECTION_WEIGHT
	#else: #neutral
		#Dialogic.VAR.ANNIE_MOOD *= SELECTION_WEIGHT
