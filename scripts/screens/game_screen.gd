extends Control

signal camera_changed(room_index: int)
signal report_submitted(room_index: int, anomaly_index: int)

const NOISE_ASSET_PATH := "res://assets/ui/noise_overlay.svg"

@onready var warning_label: Label = $WarningLabel
@onready var time_label: Label = $TimeLabel
@onready var danger_label: Label = $DangerLabel
@onready var camera_label: Label = $CameraPanel/Overlay/CameraLabel
@onready var feed_hint_label: Label = $CameraPanel/Overlay/FeedHintLabel
@onready var room_texture: TextureRect = $CameraPanel/RoomTexture
@onready var noise_texture: TextureRect = $CameraPanel/NoiseOverlay
@onready var report_panel: Panel = $ReportPanel
@onready var room_option: OptionButton = $ReportPanel/ReportBox/RoomOption
@onready var anomaly_option: OptionButton = $ReportPanel/ReportBox/AnomalyOption
@onready var message_label: Label = $MessageLabel
@onready var message_timer: Timer = $MessageTimer
@onready var room_buttons: Array[Button] = [
	$CameraButtons/Room1Button,
	$CameraButtons/Room2Button,
	$CameraButtons/Room3Button,
	$CameraButtons/Room4Button,
	$CameraButtons/Room5Button,
]

var room_names: Array = []
var anomaly_names: Array = []
var current_room_index := 0


func _ready() -> void:
	$ReportButton.pressed.connect(_open_report_panel)
	$ReportPanel/ReportBox/ReportActions/SubmitReportButton.pressed.connect(_submit_report)
	$ReportPanel/ReportBox/ReportActions/CancelReportButton.pressed.connect(_close_report_panel)
	message_timer.timeout.connect(_hide_message)
	noise_texture.texture = _load_texture(NOISE_ASSET_PATH)

	for index in range(room_buttons.size()):
		room_buttons[index].pressed.connect(_select_room.bind(index))


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if report_panel.visible:
		return

	if event.is_action_pressed("ui_left"):
		_select_relative_room(-1)
	elif event.is_action_pressed("ui_right"):
		_select_relative_room(1)


func configure(new_room_names: Array, new_anomaly_names: Array) -> void:
	room_names = new_room_names
	anomaly_names = new_anomaly_names

	room_option.clear()
	anomaly_option.clear()

	for index in range(room_names.size()):
		room_option.add_item(room_names[index])
		room_buttons[index].text = "CAM %02d" % [index + 1]

	for anomaly_name in anomaly_names:
		anomaly_option.add_item(anomaly_name)


func reset() -> void:
	current_room_index = 0
	warning_label.visible = false
	report_panel.visible = false
	message_label.visible = false
	danger_label.text = ""
	_update_button_focus()


func show_room(room_index: int, room_name: String, hint: String, texture_path: String) -> void:
	current_room_index = room_index
	camera_label.text = room_name.to_upper()
	feed_hint_label.text = hint
	room_texture.texture = _load_texture(texture_path)
	_update_button_focus()


func update_timer(elapsed_time: float, survive_duration: float) -> void:
	var remaining: int = maxi(0, int(ceil(survive_duration - elapsed_time)))
	time_label.text = "SURVIVE %02d:%02d" % [int(remaining / 60), remaining % 60]


func update_danger(active_count: int, danger_elapsed: float, danger_limit: float) -> void:
	if active_count <= 0:
		danger_label.text = "ANOMALIES: 0"
		return

	if active_count >= 3:
		var remaining: int = maxi(0, int(ceil(danger_limit - danger_elapsed)))
		danger_label.text = "ANOMALIES: %d / DANGER %02d" % [active_count, remaining]
	else:
		danger_label.text = "ANOMALIES: %d" % active_count


func show_warning() -> void:
	warning_label.visible = true


func show_fix_message() -> void:
	_show_message("FIXING ANOMALY...", 1.0)


func show_wrong_message() -> void:
	_show_message("WRONG REPORT", 1.5)


func get_current_room_index() -> int:
	return current_room_index


func _select_relative_room(offset: int) -> void:
	var next_index := (current_room_index + offset + room_names.size()) % room_names.size()
	_select_room(next_index)


func _select_room(room_index: int) -> void:
	current_room_index = room_index
	camera_changed.emit(current_room_index)


func _open_report_panel() -> void:
	report_panel.visible = true
	room_option.select(current_room_index)
	anomaly_option.select(0)


func _close_report_panel() -> void:
	report_panel.visible = false


func _submit_report() -> void:
	report_panel.visible = false
	report_submitted.emit(room_option.selected, anomaly_option.selected)


func _show_message(text: String, duration: float) -> void:
	message_label.text = text
	message_label.visible = true
	message_timer.wait_time = duration
	message_timer.start()


func _hide_message() -> void:
	message_label.visible = false


func _update_button_focus() -> void:
	for index in range(room_buttons.size()):
		room_buttons[index].disabled = index == current_room_index


func _load_texture(path: String) -> Texture2D:
	var image := Image.new()
	var error := image.load(path)

	if error != OK:
		push_warning("Could not load image: %s" % path)
		return null

	return ImageTexture.create_from_image(image)
