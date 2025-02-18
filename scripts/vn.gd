extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start('test0')
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument:String):
	if argument == "choice":
		print("choice signal recieved")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
