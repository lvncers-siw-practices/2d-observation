extends Control

signal camera_changed(room_index: int)
signal report_submitted(room_index: int, anomaly_index: int)
signal pause_requested

const NOISE_ASSET_PATH := "res://assets/ui/noise_overlay.svg"

@onready var warning_label: Label = $WarningLabel
@onready var time_label: Label = $TimeLabel
@onready var danger_label: Label = $DangerLabel
@onready var camera_label: Label = $CameraLabel
@onready var feed_hint_label: Label = $CameraPanel/Overlay/FeedHintLabel
@onready var room_container: Control = $CameraPanel/RoomContainer
@onready var noise_texture: TextureRect = $CameraPanel/NoiseOverlay
@onready var report_panel: Panel = $ReportPanel
@onready var pause_panel: Panel = $PausePanel
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
var paused := false
var current_room_scene: Control


func _ready() -> void:
	$ReportButton.pressed.connect(_open_report_panel)
	$PauseButton.pressed.connect(pause_requested.emit)
	$LeftArrowButton.pressed.connect(_select_relative_room.bind(-1))
	$RightArrowButton.pressed.connect(_select_relative_room.bind(1))
	$PausePanel/CenterBox/ResumeButton.pressed.connect(pause_requested.emit)
	$ReportPanel/ReportBox/ReportActions/SubmitReportButton.pressed.connect(_submit_report)
	$ReportPanel/ReportBox/ReportActions/CancelReportButton.pressed.connect(_close_report_panel)
	message_timer.timeout.connect(_hide_message)
	noise_texture.texture = _load_texture(NOISE_ASSET_PATH)

	for index in range(room_buttons.size()):
		room_buttons[index].pressed.connect(_select_room.bind(index))


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel"):
		pause_requested.emit()
		return

	if paused:
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
	pause_panel.visible = false
	message_label.visible = false
	paused = false
	danger_label.text = ""
	_update_button_focus()


func show_room(room_index: int, room_name: String, hint: String, room_scene_path: String, anomaly_name: String) -> void:
	current_room_index = room_index
	camera_label.text = room_name.to_upper()
	feed_hint_label.text = hint
	_load_room_scene(room_scene_path, room_name, anomaly_name)
	_update_button_focus()


func update_timer(elapsed_time: float, survive_duration: float) -> void:
	var remaining: int = maxi(0, int(ceil(survive_duration - elapsed_time)))
	time_label.text = "SURVIVE %02d:%02d" % [int(remaining / 60), remaining % 60]


func update_danger(active_count: int, danger_elapsed: float, danger_limit: float) -> void:
	if active_count <= 0:
		danger_label.text = "DEBUG anomalies: 0"
		return

	if active_count >= 3:
		var remaining: int = maxi(0, int(ceil(danger_limit - danger_elapsed)))
		danger_label.text = "DEBUG anomalies: %d / danger %02d" % [active_count, remaining]
	else:
		danger_label.text = "DEBUG anomalies: %d" % active_count


func show_warning() -> void:
	warning_label.text = "WARNING: Anomaly activity detected."
	warning_label.visible = true
	_show_message("WARNING: Anomaly detected.", 2.0)


func show_anomaly_spawned_message() -> void:
	_show_message("ANOMALY DETECTED", 2.0)


func show_fix_message() -> void:
	_show_message("FIXING ANOMALY...", 1.0)


func show_wrong_message() -> void:
	_show_message("WRONG REPORT", 1.5)


func get_current_room_index() -> int:
	return current_room_index


func set_paused(is_paused: bool) -> void:
	paused = is_paused
	pause_panel.visible = paused
	report_panel.visible = false


func _select_relative_room(offset: int) -> void:
	if paused:
		return

	var next_index := (current_room_index + offset + room_names.size()) % room_names.size()
	_select_room(next_index)


func _select_room(room_index: int) -> void:
	current_room_index = room_index
	camera_changed.emit(current_room_index)


func _open_report_panel() -> void:
	if paused:
		return

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
	var texture := load(path) as Texture2D

	if texture == null:
		push_warning("Could not load texture: %s" % path)
		return null

	return texture


func _load_room_scene(path: String, room_name: String, anomaly_name: String) -> void:
	if current_room_scene != null:
		current_room_scene.queue_free()
		current_room_scene = null

	var packed_scene := load(path) as PackedScene

	if packed_scene == null:
		push_warning("Could not load room scene: %s" % path)
		return

	current_room_scene = packed_scene.instantiate() as Control

	if current_room_scene == null:
		push_warning("Room scene root must be a Control: %s" % path)
		return

	room_container.add_child(current_room_scene)
	current_room_scene.set_anchors_preset(Control.PRESET_FULL_RECT)

	if current_room_scene.has_method("setup"):
		current_room_scene.setup(room_name, "")

	if current_room_scene.has_method("set_anomaly"):
		current_room_scene.set_anomaly(anomaly_name)
