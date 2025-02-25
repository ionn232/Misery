class_name Exploration
extends Node2D

@onready var map: Sprite2D = $map

@onready var playerController: CharacterBody2D = $Paul_UC
@onready var cameraTransform: RemoteTransform2D = $Paul_UC/cameraTransform

@onready var objects: Node2D = $Objects
@onready var room_transition_collisions: StaticBody2D = $map/room_transition_collisions

@onready var time_left: Label = $ui/ui_timer/TimeLeft
@onready var time_limit: Timer = $TimeLimit

var phase_index:int = 0

const map_v1 = preload("res://resources/Exploration/map_v1.png")
const map_first = preload("res://resources/Exploration/map_first.png")
const map_last = preload("res://resources/Exploration/map_last.png")

signal phase_concluded

func _ready():
	for object:interactable in objects.get_children():
		object.disable()

func assign_camera(cameraPath:NodePath):
	cameraTransform.remote_path = cameraPath

func _process(delta: float) -> void:
	time_left.text = seconds2hhmmss(time_limit.time_left)
	for object:Node2D in objects.get_children():
		object.global_rotation = cameraTransform.global_rotation

func load_scene(index:int):
	match index:
		0: #test scene
			for object in objects.get_children():
				object.enable()
			for collision in room_transition_collisions.get_children():
				collision.disabled = true
			map.texture = map_v1
		1: #first day exploration phase
			objects.get_child(1).enable()
			objects.get_child(2).enable()
			objects.get_child(3).enable()
			map.texture = map_first
		2: #last day exploration phase
			objects.get_child(4).enable()
			objects.get_child(5).enable()
			objects.get_child(6).enable()
			map.texture = map_last
	resume()
	phase_index = index

func seconds2hhmmss(total_seconds: float) -> String:
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hhmmss_string:String = "%02d:%05.2f" % [minutes, seconds]
	return hhmmss_string

func pause():
	playerController.is_paused = true
	playerController.push_timer.paused = true
	time_limit.paused = true

func resume():
	playerController.is_paused = false
	playerController.push_timer.paused = false
	time_limit.paused = false

func _on_time_limit_timeout() -> void:
	phase_concluded.emit()
