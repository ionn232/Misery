extends Control

@onready var label1 = $Label1
@onready var label2 = $Label2
@onready var label3 = $Label3
@onready var vbox1 = $VBoxContainer
@onready var vbox2 = $VBoxContainer2
@onready var vbox3 = $VBoxContainer3

func _ready():
	for button in vbox1.get_children():
		button.connect("pressed", _on_option_selected.bind(label1, vbox1))
	for button in vbox2.get_children():
		button.connect("pressed", _on_option_selected.bind(label2, vbox2))
	for button in vbox3.get_children():
		button.connect("pressed", _on_option_selected.bind(label3, vbox3))

func _on_option_selected(button: Button, label: Label, container: VBoxContainer):
	label.text = button.text  # Actualiza la Label con el texto del botón seleccionado
	container.visible = false  # Oculta las opciones
