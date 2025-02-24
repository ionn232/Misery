class_name Exploration
extends Node2D

@onready var playerController: CharacterBody2D = $Paul_UC
@onready var cameraTransform: RemoteTransform2D = $Paul_UC/cameraTransform

@onready var objects: Node2D = $Objects
@onready var room_transition_collisions: StaticBody2D = $map/room_transition_collisions


@onready var time_left: Label = $ui/ui_timer/TimeLeft
@onready var time_limit: Timer = $TimeLimit


func _ready():
	for object:interactable in objects.get_children():
		object.disable()


func assign_camera(cameraPath:NodePath):
	cameraTransform.remote_path = cameraPath

func _process(delta: float) -> void:
	time_left.text = seconds2hhmmss(time_limit.time_left)

func load_scene(index:int):
	match index:
		0: #test scene
			for object in objects.get_children():
				object.enable()
			for collision in room_transition_collisions.get_children():
				collision.disabled = true
		1: #first day exploration phase
			objects.get_child(1).enable()
			objects.get_child(2).enable()
			objects.get_child(3).enable()
		2: #last day exploration phase
			objects.get_child(4).enable()
			objects.get_child(5).enable()
			objects.get_child(6).enable()
	

func seconds2hhmmss(total_seconds: float) -> String:
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hhmmss_string:String = "%02d:%05.2f" % [minutes, seconds]
	return hhmmss_string
