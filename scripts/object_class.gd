class_name interactable
extends Node

@onready var collision:CollisionShape2D = $ObjectArea/CollisionShape2D


var object_name:String = ''
var dialogic_timeline_name:String = ''

func interact():
	Dialogic.start(dialogic_timeline_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func enable():
	collision.disabled = false
	self.visible = true
	
func disable():
	collision.disabled = true
	self.visible = false
