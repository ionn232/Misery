extends Node2D

@onready var camera: Camera2D = $Camera
@onready var ui: CanvasLayer = $UI

@onready var debug_menu : MenuButton = get_node("UI/DEBUG_menu")
@onready var debug_options : PopupMenu = debug_menu.get_popup()

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
	if (index == 4):
		camera.ignore_rotation = debug_options.is_item_checked(4)
		debug_options.set_item_checked(4, !debug_options.is_item_checked(4))
	
