extends Node2D

@onready var script_executer: Timer = $ScriptExecuter
@onready var choice_unlocker: Timer = $ChoiceUnlocker

const ANNIE_ACTION_CD:float = 0.5
const NEW_CHOICE_CD:float = 1.5

var current_option_index:int = -1

#annie chooses gimmick
#-1 if annie selection gimmick is not currently active, else set to choice index
var annie_objective_choice:int = -1
var choice_locked:bool = false
var annie_action_time:float = ANNIE_ACTION_CD

#new choices gimmick
var initial_choice_count:int = 0
var current_choice_count:int = 0
var max_choices_available:int = 0
var choice_addition_time:float = NEW_CHOICE_CD

var last_argument

var timeline_name:String

signal timeline_over

# Called when the node enters the scene tree for the first time.
func vn_ready() -> void:
	Dialogic.start(timeline_name)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.Choices.choice_selected.connect(_choice_made)
	get_viewport().gui_focus_changed.connect(_update_selection)
	Dialogic.timeline_ended.connect(end_phase)

func end_phase():
	timeline_over.emit()

func _choice_made(info:Dictionary):
	annie_objective_choice = -1
	choice_locked = false
	annie_action_time = ANNIE_ACTION_CD
	initial_choice_count = 0
	current_choice_count = 0
	max_choices_available = 0
	choice_addition_time = NEW_CHOICE_CD

func _update_selection(node:Control):
	current_option_index = node.get_index()

func _on_dialogic_signal(argument:Dictionary):
	last_argument = argument
	script_executer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var choices = get_tree().get_nodes_in_group('dialogic_choice_button')
	
	#Annie is choosing, she will move the selection to the desired index and trap it there
	if (choice_locked):
		choices[annie_objective_choice].grab_focus()
	elif (annie_objective_choice != -1):
		if (annie_action_time <= 0.0):
			var new_choice = current_option_index + 1 * sign(annie_objective_choice - current_option_index)
			choices[new_choice].grab_focus()
			if (new_choice == annie_objective_choice): choice_locked = true
			annie_action_time = ANNIE_ACTION_CD
		annie_action_time -= delta
	
	#New choices are being added 
	elif (max_choices_available >= 0 && current_choice_count < max_choices_available):
		if (choice_addition_time <= 0.0):
			choices[current_choice_count].visible = true
			current_choice_count += 1
			choice_addition_time = NEW_CHOICE_CD
		choice_addition_time -= delta
	
	#choices are being removed
	elif (max_choices_available >= 0 && current_choice_count > max_choices_available):
		if (choice_addition_time <= 0.0):
			if (choices[current_choice_count-1].has_focus()):
				choices[current_choice_count-2].grab_focus()
			choices[current_choice_count-1].fold_button()
			current_choice_count -= 1
			choice_addition_time = NEW_CHOICE_CD
		choice_addition_time -= delta

func _execute_after_delay() -> void:
	var choices = get_tree().get_nodes_in_group('dialogic_choice_button')
	match last_argument["type"]:
		"normal":
			if(last_argument["index"] == "0"):
				show_choices(3)
			
		"annie_chooses":
			if(last_argument["index"] == "1"):
				show_choices(3)
				annie_objective_choice = 2
		
		"new_choices":
			if(last_argument["index"] == "2"):
				show_choices(5)
				initial_choice_count = 5
				current_choice_count = initial_choice_count
				max_choices_available = 2
			

func show_choices(count:int)->void:
	var i:int=0
	var choices = get_tree().get_nodes_in_group('dialogic_choice_button')
	for choice:DialogicNode_ChoiceButton in choices:
		if (i>=count): return
		choice.visible = true
		i += 1
