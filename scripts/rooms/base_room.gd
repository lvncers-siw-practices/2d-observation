extends Control

@export var room_name := ""
@export var texture_path := ""

@onready var background_texture: TextureRect = $BackgroundTexture
@onready var room_name_label: Label = $AnomalyLayer/RoomNameLabel
@onready var anomaly_label: Label = $AnomalyLayer/AnomalyLabel


func _ready() -> void:
	_apply_room_data()


func setup(new_room_name: String, new_texture_path: String) -> void:
	room_name = new_room_name

	if not new_texture_path.is_empty():
		texture_path = new_texture_path

	_apply_room_data()


func set_anomaly(anomaly_name: String) -> void:
	if anomaly_name.is_empty():
		anomaly_label.visible = false
		anomaly_label.text = ""
		return

	anomaly_label.visible = true
	anomaly_label.text = "ANOMALY: %s" % anomaly_name


func _apply_room_data() -> void:
	if not is_node_ready():
		return

	room_name_label.text = room_name.to_upper()
	background_texture.texture = _load_texture(texture_path)


func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null

	var texture := load(path) as Texture2D

	if texture == null:
		push_warning("Could not load room texture: %s" % path)
		return null

	return texture
