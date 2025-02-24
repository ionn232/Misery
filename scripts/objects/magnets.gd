extends interactable

func _ready():
	$Sprite.play('default')
	object_name = "pictures with magnets"
	dialogic_timeline_name = 'object_magnets'
