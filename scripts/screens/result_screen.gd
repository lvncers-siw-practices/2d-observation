extends Control

signal retry_requested
signal title_requested


func _ready() -> void:
	$CenterBox/RetryButton.pressed.connect(retry_requested.emit)
	$CenterBox/TitleButton.pressed.connect(title_requested.emit)


func set_result(title: String, detail: String, retry_text: String) -> void:
	$CenterBox/ResultLabel.text = title
	$CenterBox/DetailLabel.text = detail
	$CenterBox/RetryButton.text = retry_text
