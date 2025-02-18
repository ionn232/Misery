extends interactable

func _ready():
	$Sprite.play('default')
	object_name = "test_object"
	dialogic_timeline_name = 'test_object'
