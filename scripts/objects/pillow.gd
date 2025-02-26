extends interactable

func _ready():
	$Sprite.play('default')
	object_name = "pillow with needlework"
	dialogic_timeline_name = 'object_pillow'
