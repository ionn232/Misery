extends interactable

func _ready():
	$Sprite.play('default')
	object_name = "portrait"
	dialogic_timeline_name = 'object_portrait'
