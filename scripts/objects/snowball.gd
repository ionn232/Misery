extends interactable

func _ready():
	$Sprite.play('default')
	object_name = "snowglobe"
	dialogic_timeline_name = 'object_snowball'
