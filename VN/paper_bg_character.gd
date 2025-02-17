@tool
extends DialogicPortrait

@onready var sprite: AnimatedSprite2D = $Sprite

### Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print('ready')
	#sprite.play("unfold")
	pass

func _get_covered_rect() -> Rect2:
	return Rect2($Sprite.position, $Sprite.sprite_frames.get_frame_texture($Sprite.animation, 0).get_size()*$Sprite.scale)
