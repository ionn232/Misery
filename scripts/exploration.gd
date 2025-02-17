class_name Exploration
extends Node2D

@onready var playerController: CharacterBody2D = $Paul_UC
@onready var cameraTransform: RemoteTransform2D = $Paul_UC/cameraTransform

@onready var time_left: Label = $ui/ui_timer/TimeLeft
@onready var time_limit: Timer = $TimeLimit


#func _ready():
	#cameraTransform.remote_path = camera.get_path()

func assign_camera(cameraPath:NodePath):
	cameraTransform.remote_path = cameraPath

func _process(delta: float) -> void:
	time_left.text = seconds2hhmmss(time_limit.time_left)


func seconds2hhmmss(total_seconds: float) -> String:
	#total_seconds = 12345
	var seconds:float = fmod(total_seconds , 60.0)
	var minutes:int   =  int(total_seconds / 60.0) % 60
	var hhmmss_string:String = "%02d:%05.2f" % [minutes, seconds]
	return hhmmss_string
