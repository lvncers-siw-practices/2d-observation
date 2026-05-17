extends Control

const GameState := preload("res://scripts/game_state.gd")

@onready var title_screen: Control = $TitleScreen
@onready var game_screen: Control = $GameScreen
@onready var result_screen: Control = $ResultScreen

var game_state: GameState
var paused := false


func _ready() -> void:
	game_state = GameState.new()
	game_state.warning_triggered.connect(_on_warning_triggered)
	game_state.anomaly_spawned.connect(_on_anomaly_spawned)
	game_state.game_cleared.connect(_show_game_clear)
	game_state.game_over.connect(_show_game_over)

	title_screen.start_requested.connect(_start_game)
	title_screen.quit_requested.connect(_quit_game)
	game_screen.camera_changed.connect(_refresh_room_view)
	game_screen.report_submitted.connect(_submit_report)
	game_screen.pause_requested.connect(_toggle_pause)
	result_screen.retry_requested.connect(_start_game)
	result_screen.title_requested.connect(_show_title)

	_show_title()


func _process(delta: float) -> void:
	if game_state == null or not game_state.active or paused:
		return

	game_state.tick(delta)
	game_screen.update_timer(game_state.elapsed_time, GameState.SURVIVE_DURATION)
	game_screen.update_danger(
		game_state.get_active_anomaly_count(),
		game_state.danger_elapsed,
		GameState.GAME_OVER_DANGER_DURATION
	)


func _start_game() -> void:
	paused = false
	game_state.start()
	game_screen.configure(game_state.get_room_names(), game_state.get_anomaly_names())
	game_screen.reset()
	game_screen.set_paused(false)
	_refresh_room_view(0)
	_update_hud()
	_show_screen(game_screen)


func _submit_report(room_index: int, anomaly_index: int) -> void:
	if game_state.report(room_index, anomaly_index):
		game_screen.show_fix_message()
		_refresh_room_view(game_screen.get_current_room_index())
	else:
		game_screen.show_wrong_message()

	_update_hud()


func _refresh_room_view(room_index: int) -> void:
	var room_names := game_state.get_room_names()
	game_screen.show_room(
		room_index,
		room_names[room_index],
		game_state.get_room_hint(room_index),
		game_state.get_room_texture_path(room_index)
	)


func _on_warning_triggered() -> void:
	game_screen.show_warning()


func _on_anomaly_spawned(room_index: int, _anomaly_index: int) -> void:
	game_screen.show_anomaly_spawned_message()
	_update_hud()

	if room_index == game_screen.get_current_room_index():
		_refresh_room_view(room_index)


func _toggle_pause() -> void:
	if game_state == null or not game_state.active or not game_screen.visible:
		return

	paused = not paused
	game_screen.set_paused(paused)


func _show_title() -> void:
	if game_state != null:
		game_state.active = false

	paused = false
	_show_screen(title_screen)


func _show_game_over() -> void:
	paused = false
	game_screen.set_paused(false)
	result_screen.set_result(
		"GAMEOVER",
		"Three anomalies stayed active for too long.",
		"RETRY"
	)
	_show_screen(result_screen)


func _show_game_clear() -> void:
	paused = false
	game_screen.set_paused(false)
	result_screen.set_result(
		"GAMECLEAR",
		"You survived the full six minutes.",
		"PLAY AGAIN"
	)
	_show_screen(result_screen)


func _show_screen(screen: Control) -> void:
	title_screen.visible = screen == title_screen
	game_screen.visible = screen == game_screen
	result_screen.visible = screen == result_screen


func _update_hud() -> void:
	game_screen.update_timer(game_state.elapsed_time, GameState.SURVIVE_DURATION)
	game_screen.update_danger(
		game_state.get_active_anomaly_count(),
		game_state.danger_elapsed,
		GameState.GAME_OVER_DANGER_DURATION
	)


func _quit_game() -> void:
	get_tree().quit()
