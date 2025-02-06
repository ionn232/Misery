extends Node2D

@export var camera:Camera2D
@onready var playerController: CharacterBody2D = $Paul_UC
@onready var cameraTransform: RemoteTransform2D = $Paul_UC/cameraTransform

func _ready():
	cameraTransform.remote_path = camera.get_path()

# Make camera follow Paul whenever exploration phase is active
func _process(delta: float) -> void:
	pass
