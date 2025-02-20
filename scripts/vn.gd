extends Node2D

@onready var script_executer: Timer = $ScriptExecuter
@onready var annie_input_cooldown: Timer = $AnnieInputCooldown

var current_option_index:int = -1

#-1 if annie selection gimmick is not currently active, else set to choice index
var annie_objective_choice:int = -1

#auxiliary variable. set to 1 if annie choosing gimmick is not active.
#node arrays dont start with 0 ??? idk
var annie_current_choice:int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start('test0')
	Dialogic.signal_event.connect(_on_dialogic_signal)
	get_viewport().gui_focus_changed.connect(_update_selection)
	#Viewport.gui_focus_changed.connect(_update_selection)
	#Dialogic.Choices.question_shown.connect(_on_dialogic_signal)

func _update_selection(node:Control):
	current_option_index = node.get_index() + 1

func _on_dialogic_signal(argument:Dictionary):
	if argument["type"] == "annie_chooses":
		if(argument["index"] == "0"):
			var choices = get_tree().get_nodes_in_group('dialogic_choice_button')
			print('signal recieved for test scene: chapter 0 interaction 0')
			script_executer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#Annie is choosing, she will select
	if (annie_objective_choice != -1):
		if (annie_input_cooldown.time_left == 0.0):
			annie_input_cooldown.start()
	
	pass

func _execute_after_delay() -> void:
	var choices = get_tree().get_nodes_in_group('dialogic_choice_button')
	print('executing gimmick')
	annie_objective_choice = 3

func _annie_action() -> void:
	annie_current_choice = current_option_index
	if !(annie_current_choice == annie_objective_choice):
		var choices = get_tree().get_nodes_in_group('dialogic_choice_button')
		choices[annie_current_choice].grab_focus()
		annie_current_choice += 1 * sign(annie_objective_choice)
		print('selecting choice ', annie_current_choice)
		annie_input_cooldown.start()
	else:
		Input.action_press("dialogic_default_action")
		Input.action_release("dialogic_default_action")
		Dialogic.Inputs.dialogic_action.emit()
		print('option selected by annie! ', annie_current_choice)
		annie_objective_choice = -1
		annie_current_choice = 1
