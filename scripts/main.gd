extends Control

const ROOM_NAMES := [
	"Room 1",
	"Room 2",
	"Room 3",
	"Room 4",
	"Room 5",
]
const ANOMALY_NAMES := [
	"Door Open",
	"Shadow",
	"Missing Object",
	"Camera Noise",
]
const TARGET_ROOM_INDEX := 2
const TARGET_ANOMALY_INDEX := 0
const WARNING_DELAY := 20.0
const GAME_OVER_DELAY := 40.0

@onready var title_screen: Control = $TitleScreen
@onready var game_screen: Control = $GameScreen
@onready var game_over_screen: Control = $GameOverScreen
@onready var game_clear_screen: Control = $GameClearScreen
@onready var warning_label: Label = $GameScreen/WarningLabel
@onready var time_label: Label = $GameScreen/TimeLabel
@onready var camera_label: Label = $GameScreen/CameraPanel/CameraLabel
@onready var feed_hint_label: Label = $GameScreen/CameraPanel/FeedHintLabel
@onready var report_panel: Panel = $GameScreen/ReportPanel
@onready var room_option: OptionButton = $GameScreen/ReportPanel/ReportBox/RoomOption
@onready var anomaly_option: OptionButton = $GameScreen/ReportPanel/ReportBox/AnomalyOption
@onready var message_label: Label = $GameScreen/MessageLabel
@onready var message_timer: Timer = $MessageTimer
@onready var fix_timer: Timer = $FixTimer

@onready var room_buttons: Array[Button] = [
	$GameScreen/CameraButtons/Room1Button,
	$GameScreen/CameraButtons/Room2Button,
	$GameScreen/CameraButtons/Room3Button,
	$GameScreen/CameraButtons/Room4Button,
	$GameScreen/CameraButtons/Room5Button,
]

var current_room_index := 0
var elapsed_time := 0.0
var game_active := false
var warning_shown := false
var anomaly_fixed := false


func _ready() -> void:
	$TitleScreen/CenterBox/StartButton.pressed.connect(_start_game)
	$TitleScreen/CenterBox/QuitButton.pressed.connect(_quit_game)
	$GameScreen/ReportButton.pressed.connect(_open_report_panel)
	$GameScreen/ReportPanel/ReportBox/ReportActions/SubmitReportButton.pressed.connect(_submit_report)
	$GameScreen/ReportPanel/ReportBox/ReportActions/CancelReportButton.pressed.connect(_close_report_panel)
	$GameOverScreen/CenterBox/RetryButton.pressed.connect(_start_game)
	$GameOverScreen/CenterBox/TitleButton.pressed.connect(_show_title)
	$GameClearScreen/CenterBox/PlayAgainButton.pressed.connect(_start_game)
	$GameClearScreen/CenterBox/TitleButton.pressed.connect(_show_title)
	message_timer.timeout.connect(_hide_message)
	fix_timer.timeout.connect(_show_game_clear)

	for index in range(room_buttons.size()):
		room_buttons[index].pressed.connect(_select_room.bind(index))

	_setup_report_options()
	_show_title()


func _process(delta: float) -> void:
	if not game_active:
		return

	elapsed_time += delta
	_update_time_label()

	if not warning_shown and elapsed_time >= WARNING_DELAY:
		warning_shown = true
		warning_label.visible = true

	if elapsed_time >= GAME_OVER_DELAY:
		_show_game_over()


func _setup_report_options() -> void:
	room_option.clear()
	anomaly_option.clear()

	for room_name in ROOM_NAMES:
		room_option.add_item(room_name)

	for anomaly_name in ANOMALY_NAMES:
		anomaly_option.add_item(anomaly_name)


func _start_game() -> void:
	current_room_index = 0
	elapsed_time = 0.0
	game_active = true
	warning_shown = false
	anomaly_fixed = false
	warning_label.visible = false
	report_panel.visible = false
	message_label.visible = false
	_update_time_label()
	_select_room(current_room_index)
	_show_screen(game_screen)


func _show_title() -> void:
	game_active = false
	report_panel.visible = false
	message_label.visible = false
	_show_screen(title_screen)


func _show_game_over() -> void:
	game_active = false
	report_panel.visible = false
	_show_screen(game_over_screen)


func _show_game_clear() -> void:
	game_active = false
	report_panel.visible = false
	_show_screen(game_clear_screen)


func _show_screen(screen: Control) -> void:
	title_screen.visible = screen == title_screen
	game_screen.visible = screen == game_screen
	game_over_screen.visible = screen == game_over_screen
	game_clear_screen.visible = screen == game_clear_screen


func _select_room(room_index: int) -> void:
	current_room_index = room_index
	camera_label.text = ROOM_NAMES[current_room_index].to_upper()

	if not anomaly_fixed and current_room_index == TARGET_ROOM_INDEX:
		feed_hint_label.text = "Temporary anomaly: the door is open."
	else:
		feed_hint_label.text = "Temporary feed placeholder"


func _open_report_panel() -> void:
	report_panel.visible = true
	room_option.select(current_room_index)
	anomaly_option.select(0)


func _close_report_panel() -> void:
	report_panel.visible = false


func _submit_report() -> void:
	var reported_room := room_option.selected
	var reported_anomaly := anomaly_option.selected
	var is_correct := reported_room == TARGET_ROOM_INDEX and reported_anomaly == TARGET_ANOMALY_INDEX

	report_panel.visible = false

	if is_correct:
		anomaly_fixed = true
		game_active = false
		_show_message("FIXING ANOMALY...", 1.0)
		fix_timer.start()
	else:
		_show_message("WRONG REPORT", 1.5)


func _show_message(text: String, duration: float) -> void:
	message_label.text = text
	message_label.visible = true
	message_timer.wait_time = duration
	message_timer.start()


func _hide_message() -> void:
	message_label.visible = false


func _update_time_label() -> void:
	var seconds := int(elapsed_time)
	time_label.text = "%02d:%02d" % [int(seconds / 60), seconds % 60]


func _quit_game() -> void:
	get_tree().quit()
