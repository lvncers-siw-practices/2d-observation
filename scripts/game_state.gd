extends RefCounted

signal warning_triggered
signal game_cleared
signal game_over

const SURVIVE_DURATION := 360.0
const WARNING_DELAY := 20.0
const GAME_OVER_ACTIVE_COUNT := 3
const GAME_OVER_DANGER_DURATION := 40.0

const ROOM_NAMES := [
	"Apartment Hall",
	"Security Office",
	"Storage Room",
	"Elevator Front",
	"Dark Room",
]
const ANOMALY_NAMES := [
	"Door Open",
	"Shadow",
	"Missing Object",
	"Camera Noise",
]
const ROOM_TEXTURES := [
	"res://assets/rooms/room_01.svg",
	"res://assets/rooms/room_02.svg",
	"res://assets/rooms/room_03.svg",
	"res://assets/rooms/room_04.svg",
	"res://assets/rooms/room_05.svg",
]

var elapsed_time := 0.0
var danger_elapsed := 0.0
var active := false
var warning_emitted := false
var anomalies: Array[Dictionary] = []


func start() -> void:
	elapsed_time = 0.0
	danger_elapsed = 0.0
	active = true
	warning_emitted = false
	anomalies = [
		{"room_index": 0, "anomaly_index": 1, "fixed": false},
		{"room_index": 2, "anomaly_index": 0, "fixed": false},
		{"room_index": 4, "anomaly_index": 3, "fixed": false},
	]


func tick(delta: float) -> void:
	if not active:
		return

	elapsed_time += delta

	if not warning_emitted and elapsed_time >= WARNING_DELAY:
		warning_emitted = true
		warning_triggered.emit()

	if elapsed_time >= SURVIVE_DURATION:
		active = false
		game_cleared.emit()
		return

	if get_active_anomaly_count() >= GAME_OVER_ACTIVE_COUNT:
		danger_elapsed += delta
	else:
		danger_elapsed = 0.0

	if danger_elapsed >= GAME_OVER_DANGER_DURATION:
		active = false
		game_over.emit()


func report(room_index: int, anomaly_index: int) -> bool:
	for anomaly in anomalies:
		if anomaly["fixed"]:
			continue

		if anomaly["room_index"] == room_index and anomaly["anomaly_index"] == anomaly_index:
			anomaly["fixed"] = true
			danger_elapsed = 0.0
			return true

	return false


func get_room_names() -> Array:
	return ROOM_NAMES.duplicate()


func get_anomaly_names() -> Array:
	return ANOMALY_NAMES.duplicate()


func get_room_texture_path(room_index: int) -> String:
	return ROOM_TEXTURES[room_index]


func get_room_hint(room_index: int) -> String:
	for anomaly in anomalies:
		if anomaly["fixed"]:
			continue

		if anomaly["room_index"] == room_index:
			return "Anomaly: %s" % ANOMALY_NAMES[anomaly["anomaly_index"]]

	return "No obvious movement."


func get_active_anomaly_count() -> int:
	var count := 0

	for anomaly in anomalies:
		if not anomaly["fixed"]:
			count += 1

	return count
