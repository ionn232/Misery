extends Node2D

@onready var camera: Camera2D = $Camera
@onready var ui: CanvasLayer = $UI

@onready var debug_menu : MenuButton = get_node("UI/DEBUG_menu")
@onready var debug_options : PopupMenu = debug_menu.get_popup()

@onready var remove_scene_delay: Timer = $RemoveSceneDelay

const EXPLORATION = preload("res://scenes/exploration_test.tscn")
const INTERACTION_TEST = preload("res://scenes/interaction_test.tscn")
const WRITING_TEST = preload("res://scenes/writing_test.tscn")

var scene_aux
var current_phase:int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debug_options.id_pressed.connect(handle_option)
	camera.rotation_smoothing_enabled = true
	camera.position_smoothing_enabled = true

func _process(delta: float) -> void:	
	#program exit
	if (Input.is_action_just_pressed("ui_cancel")):
		get_tree().quit()
	#restart scene
	if (Input.is_action_just_pressed("DEBUG_reset")):
		get_tree().reload_current_scene()
	#debug options
	if (Input.is_action_just_pressed("DEBUG_1")):
		handle_option(1)
	elif (Input.is_action_just_pressed("DEBUG_2")):
		handle_option(2)
	elif (Input.is_action_just_pressed("DEBUG_3")):
		handle_option(3)
	elif (Input.is_action_just_pressed("DEBUG_4")):
		handle_option(4)
	elif (Input.is_action_just_pressed("DEBUG_5")):
		handle_option(5)

func handle_option(index: int):
	match index:
		1:
			var first_exploration = EXPLORATION.instantiate()
			add_child(first_exploration)
			first_exploration.assign_camera(camera.get_path())
			first_exploration.load_scene(1)
			first_exploration.phase_concluded.connect(next_scene.bind(first_exploration))
		2:
			var test_exploration = EXPLORATION.instantiate()
			add_child(test_exploration)
			test_exploration.assign_camera(camera.get_path())
			test_exploration.load_scene(0)
		3:
			var test_writing = WRITING_TEST.instantiate()
			add_child(test_writing)
			test_writing.load_scene(0)
		4:
			var test_interaction = INTERACTION_TEST.instantiate()
			add_child(test_interaction)
			test_interaction.load_scene(0)
		#lock/unlock camera rotation
		5:
			camera.ignore_rotation = debug_options.is_item_checked(4)
			debug_options.set_item_checked(4, !debug_options.is_item_checked(4))

func next_scene(phase):
	match phase:
		_ when ((phase.name == "Exploration") && (phase.phase_index == 1)):
			phase.queue_free()
			var first_writing = WRITING_TEST.instantiate()
			add_child(first_writing)
			first_writing.load_scene(1)
			camera.position_smoothing_enabled = false
			camera.rotation_smoothing_enabled = false
			camera.global_transform = Transform2D(0, Vector2(960, 540))
			first_writing.phase_concluded.connect(next_scene.bind(first_writing))
			
		_ when ((phase.name == "Writing") && (phase.phase_index == 1)):
			remove_scene_delayed(phase)
			var first_interaction = INTERACTION_TEST.instantiate()
			add_child(first_interaction)
			first_interaction.load_scene(1 + get_interaction_offset())
			first_interaction.phase_concluded.connect(next_scene.bind(first_interaction))
			
		_ when ((phase.name == "Interaction") && (phase.phase_index == 1)):
			phase.queue_free()
			scene_aux.phase_concluded.connect(next_scene.bind(scene_aux))
			camera.rotation_smoothing_enabled = true
			camera.position_smoothing_enabled = true
			current_phase = 2
			
		_ when ((phase.name == "Exploration") && (phase.phase_index == 2)):
			phase.queue_free()
			var last_writing = WRITING_TEST.instantiate()
			add_child(last_writing)
			last_writing.load_scene(2)
			camera.position_smoothing_enabled = false
			camera.rotation_smoothing_enabled = false
			camera.global_transform = Transform2D(0, Vector2(960, 540))
			last_writing.phase_concluded.connect(next_scene.bind(last_writing))
			
		_ when ((phase.name == "Writing") && (phase.phase_index == 2)):
			remove_scene_delayed(phase)
			var last_interaction = INTERACTION_TEST.instantiate()
			add_child(last_interaction)
			last_interaction.load_scene(4 + + get_interaction_offset())
			last_interaction.phase_concluded.connect(next_scene.bind(last_interaction))
			
		_ when ((phase.name == "Interaction") && (phase.phase_index == 2)):
			phase.queue_free()
			get_tree().reload_current_scene()

func get_interaction_offset() -> int:
	var annie_mood = Dialogic.VAR.ANNIE_MOOD
	if (annie_mood <= -1.0): # annie is irritable
		return 2
	elif (annie_mood < 1.0): # annie is neutral
		return 0
	else: # annie is manic
		return 1

func remove_scene_delayed(scene):
	scene_aux = scene
	remove_scene_delay.start()

func _on_remove_scene_delay_timeout() -> void:
	scene_aux.queue_free()
	if (current_phase == 1): #preload next exploration (paused)
		var last_exploration = EXPLORATION.instantiate()
		scene_aux = last_exploration
		add_child(scene_aux)
		scene_aux.assign_camera(camera.get_path())
		scene_aux.load_scene(2)
		scene_aux.pause()
