extends AnimatedSprite2D

const F_0 = preload("res://resources/Interaction/f0.png")
const F_1 = preload("res://resources/Interaction/f1.png")
const F_2 = preload("res://resources/Interaction/f2.png")
const F_3 = preload("res://resources/Interaction/f3.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.play("unfold")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
