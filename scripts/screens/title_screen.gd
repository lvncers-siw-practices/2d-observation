extends Control

signal start_requested
signal quit_requested


func _ready() -> void:
	$CenterBox/StartButton.pressed.connect(start_requested.emit)
	$CenterBox/QuitButton.pressed.connect(quit_requested.emit)
