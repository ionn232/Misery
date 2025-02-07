class_name Exploration
extends Node2D

@onready var playerController: CharacterBody2D = $Paul_UC
@onready var cameraTransform: RemoteTransform2D = $Paul_UC/cameraTransform

#func _ready():
	#cameraTransform.remote_path = camera.get_path()

func assign_camera(cameraPath:NodePath):
	cameraTransform.remote_path = cameraPath
