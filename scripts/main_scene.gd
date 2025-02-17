extends Node2D

@onready var camera: Camera2D = $Camera
@onready var ui: CanvasLayer = $UI

@onready var debug_menu : MenuButton = get_node("UI/DEBUG_menu")
@onready var debug_options : PopupMenu = debug_menu.get_popup()


const EXPLORATION_TEST = preload("res://scenes/exploration_test.tscn")
const INTERACTION_TEST = preload("res://scenes/interaction_test.tscn")
const WRITING_TEST = preload("res://scenes/writing_test.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debug_options.id_pressed.connect(handle_option)


func _process(delta: float) -> void:
	#program exit
	if (Input.is_action_just_pressed("ui_cancel")):
		get_tree().quit()
	#restart scene
	if (Input.is_action_just_pressed("DEBUG_reset")):
		get_tree().reload_current_scene()
		

func handle_option(index: int):
	#lock/unlock camera rotation
	if (index == 1 || Input.is_action_just_pressed("DEBUG_1")):
		#var test_exploration = Exploration.new()
		#add_child(test_exploration)
		#test_exploration.assign_camera(camera.get_path())
		var test_exploration = EXPLORATION_TEST.instantiate()
		add_child(test_exploration)
		test_exploration.assign_camera(camera.get_path())
	if (index == 2 || Input.is_action_just_pressed("DEBUG_2")):
		var test_writing = WRITING_TEST.instantiate()
		add_child(test_writing)
	if (index == 3 || Input.is_action_just_pressed("DEBUG_3")):
		var test_interaction = INTERACTION_TEST.instantiate()
		add_child(test_interaction)
	if (index == 4 || Input.is_action_just_pressed("DEBUG_4")):
		camera.ignore_rotation = debug_options.is_item_checked(4)
		debug_options.set_item_checked(4, !debug_options.is_item_checked(4))
	
