extends Control

const DISCOVERY_DATA_PATH := "res://data/discovery/prototype_discovery.json"

var data: Dictionary = {}
var inspected: Dictionary = {}
var inspect_count: int = 0
var object_buttons: Dictionary = {}

@onready var title_label: Label = $Margin/Scroll/Root/HeaderPanel/HeaderMargin/HeaderStack/TitleLabel
@onready var intro_label: Label = $Margin/Scroll/Root/IntroPanel/IntroMargin/IntroLabel
@onready var observation_label: Label = $Margin/Scroll/Root/ObservationPanel/ObservationMargin/ObservationLabel
@onready var note_label: Label = $Margin/Scroll/Root/NotePanel/NoteMargin/NoteLabel
@onready var object_caption: Label = $Margin/Scroll/Root/ObjectCaption
@onready var object_row: GridContainer = $Margin/Scroll/Root/ObjectRow
@onready var target_panel: VBoxContainer = $Margin/Scroll/Root/TargetPanel
@onready var end_panel: VBoxContainer = $Margin/Scroll/Root/EndPanel
@onready var open_button: Button = $Margin/Scroll/Root/OpenButton
@onready var network_button: Button = $Margin/Scroll/Root/EndPanel/NetworkButton
@onready var restart_button: Button = $Margin/Scroll/Root/EndPanel/RestartButton
@onready var coaster_button: Button = $Margin/Scroll/Root/TargetPanel/TargetGrid/CoasterButton
@onready var lighter_button: Button = $Margin/Scroll/Root/TargetPanel/TargetGrid/LighterButton
@onready var adapter_button: Button = $Margin/Scroll/Root/TargetPanel/TargetGrid/AdapterButton
@onready var unsure_button: Button = $Margin/Scroll/Root/TargetPanel/TargetGrid/UnsureButton

func _ready() -> void:
	_load_data()
	open_button.pressed.connect(_open_box)
	network_button.pressed.connect(_go_to_network)
	restart_button.pressed.connect(_restart)
	coaster_button.pressed.connect(func(): _choose_target("coaster"))
	lighter_button.pressed.connect(func(): _choose_target("lighter"))
	adapter_button.pressed.connect(func(): _choose_target("adapter"))
	unsure_button.pressed.connect(func(): _choose_target("unsure"))
	_show_entry()

func _load_data() -> void:
	if not FileAccess.file_exists(DISCOVERY_DATA_PATH):
		push_error("Discovery data not found: %s" % DISCOVERY_DATA_PATH)
		return

	var file := FileAccess.open(DISCOVERY_DATA_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		data = parsed
	else:
		push_error("Discovery data is invalid JSON.")


func _show_entry() -> void:
	var result: Dictionary = AuctionState.lot_results.get("lot02", {})
	var owns_lot02 := str(result.get("winner", "")) == "mc"

	if not owns_lot02:
		intro_label.text = "Kotak Campuran bukan milikmu."
		open_button.visible = false
		observation_label.text = "Lot 02 dimenangkan orang lain, jadi kotak itu tidak pernah sampai ke rumahmu."
		note_label.text = "Tidak ada pemeriksaan yang bisa dilakukan pada barang yang tidak kamu miliki."
		end_panel.visible = true
		return

	var lot_data: Dictionary = data.get("lot02", {})
	intro_label.text = str(lot_data.get("intro", "Kotak Campuran ada di depanmu."))
	observation_label.text = str(lot_data.get("source_story", "Kotak ini berasal dari Lot 02 yang kamu menangkan."))
	note_label.text = "Di ruang lelang kamu belum boleh membongkar isinya."

func _open_box() -> void:
	open_button.visible = false
	object_caption.visible = true
	object_row.visible = true

	var lot_data: Dictionary = data.get("lot02", {})
	intro_label.text = str(lot_data.get("open_text", "Kotak dibuka."))

	var objects: Array = lot_data.get("objects", [])
	for i in range(objects.size()):
		var object_data: Dictionary = objects[i]
		var button := Button.new()
		button.text = str(object_data.get("label", "OBJEK"))
		button.custom_minimum_size = Vector2(175, 68)
		var object_id := str(object_data.get("id", "object_%d" % i))
		button.pressed.connect(func(): _inspect_object(object_id))
		object_row.add_child(button)
		object_buttons[object_id] = button

	observation_label.text = str(lot_data.get("selection_reason", "Tiga benda paling membuatmu penasaran."))
	note_label.text = "Kamu tidak sedang memilih barang terbaik. Kamu memilih bagian yang pertanyaannya belum selesai."

func _inspect_object(object_id: String) -> void:
	var object_data := _get_object(object_id)
	if object_data.is_empty():
		return

	if not inspected.has(object_id):
		inspected[object_id] = true
		inspect_count += 1

	var observation := str(object_data.get("observation", "Tidak ada observasi."))
	var note := str(object_data.get("note", "Belum ada catatan."))

	observation_label.text = "%s — %s" % [
		str(object_data.get("label", "OBJEK")),
		observation
	]
	note_label.text = "CATATAN SEMENTARA\n%s" % note

	AuctionState.discovery_notes[object_id] = {
		"observation": observation,
		"note": note,
		"status": "unresolved"
	}

	_refresh_object_states()

	if inspect_count >= 2:
		target_panel.visible = true

func _refresh_object_states() -> void:
	for object_id in object_buttons.keys():
		var button: Button = object_buttons[object_id]
		button.theme_type_variation = &"SelectedButton" if inspected.has(object_id) else &""

func _choose_target(target_id: String) -> void:
	target_panel.visible = false
	object_caption.visible = false
	object_row.visible = false

	if target_id == "unsure":
		AuctionState.discovery_target = "unsure"
		observation_label.text = "Kamu belum cukup yakin untuk menentukan arah pencarian."
		note_label.text = "Tidak memilih kategori juga sebuah keputusan. Kamu tetap bisa bertanya, tetapi pertanyaanmu masih luas."
	else:
		var object_data := _get_object(target_id)
		AuctionState.discovery_target = target_id
		observation_label.text = "Kamu memilih: %s" % str(object_data.get("label", target_id)).to_upper()
		note_label.text = "%s\n\n%s" % [
			str(object_data.get("note", "")),
			str(object_data.get("next_question", "Butuh konteks lebih lanjut."))
		]

	intro_label.text = "Kamu sudah punya pertanyaan. Belum punya jawabannya."
	observation_label.text += "\n\nKamu teringat ucapan Pak Slamet: kalau butuh orang yang tahu orang, cari Pak Wira di Pasar Tua."
	end_panel.visible = true
	network_button.visible = true

func _get_object(object_id: String) -> Dictionary:
	var lot_data: Dictionary = data.get("lot02", {})
	var objects: Array = lot_data.get("objects", [])
	for value in objects:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var object_data: Dictionary = value
		if str(object_data.get("id", "")) == object_id:
			return object_data
	return {}

func _go_to_network() -> void:
	get_tree().change_scene_to_file("res://scenes/network/human_network.tscn")

func _restart() -> void:
	AuctionState.reset_prototype()
	get_tree().change_scene_to_file("res://scenes/auction/auction_room.tscn")
