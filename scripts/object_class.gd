class_name interactable
extends Node

var object_name:String = ''
var dialogic_timeline_name:String = ''

func interact():
	Dialogic.start(dialogic_timeline_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
