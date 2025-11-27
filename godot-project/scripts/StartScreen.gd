extends Control

func _ready():
	$MarginContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$MarginContainer/VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_close_pressed():
	get_tree().quit()