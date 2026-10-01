extends Control

const DISCOVERY_DATA_PATH := "res://data/discovery/prototype_discovery.json"

var data: Dictionary = {}
var inspected: Dictionary = {}
var inspect_count: int = 0

var title_label: Label
var intro_label: Label
var observation_label: Label
var note_label: Label
var object_row: HBoxContainer
var target_panel: VBoxContainer
var end_panel: VBoxContainer
var open_button: Button
var network_button: Button

func _ready() -> void:
	_load_data()
	_build_ui()
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

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#1d1815")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 38)
	margin.add_theme_constant_override("margin_bottom", 38)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	title_label = Label.new()
	title_label.text = "MEJA PEMERIKSAAN"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 30)
	root.add_child(title_label)

	intro_label = Label.new()
	intro_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro_label.add_theme_font_size_override("font_size", 19)
	root.add_child(intro_label)

	open_button = Button.new()
	open_button.text = "BUKA KOTAK"
	open_button.custom_minimum_size = Vector2(250, 72)
	open_button.pressed.connect(_open_box)
	root.add_child(open_button)

	object_row = HBoxContainer.new()
	object_row.alignment = BoxContainer.ALIGNMENT_CENTER
	object_row.add_theme_constant_override("separation", 10)
	object_row.visible = false
	root.add_child(object_row)

	observation_label = Label.new()
	observation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	observation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	observation_label.custom_minimum_size = Vector2(0, 150)
	observation_label.add_theme_font_size_override("font_size", 19)
	root.add_child(observation_label)

	note_label = Label.new()
	note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_label.custom_minimum_size = Vector2(0, 120)
	note_label.add_theme_font_size_override("font_size", 18)
	root.add_child(note_label)

	target_panel = VBoxContainer.new()
	target_panel.visible = false
	target_panel.add_theme_constant_override("separation", 10)
	root.add_child(target_panel)

	var target_title := Label.new()
	target_title.text = "TEMUAN MANA YANG LAYAK DIKEJAR?"
	target_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_title.add_theme_font_size_override("font_size", 20)
	target_panel.add_child(target_title)

	var target_row := HBoxContainer.new()
	target_row.alignment = BoxContainer.ALIGNMENT_CENTER
	target_row.add_theme_constant_override("separation", 8)
	target_panel.add_child(target_row)

	for target in [
		{"id":"coaster","label":"TATAKAN"},
		{"id":"lighter","label":"KOREK"},
		{"id":"adapter","label":"ADAPTOR"},
		{"id":"unsure","label":"BELUM YAKIN"}
	]:
		var button := Button.new()
		button.text = target.label
		button.custom_minimum_size = Vector2(145, 62)
		var target_id: String = target.id
		button.pressed.connect(func(): _choose_target(target_id))
		target_row.add_child(button)

	end_panel = VBoxContainer.new()
	end_panel.visible = false
	end_panel.add_theme_constant_override("separation", 12)
	root.add_child(end_panel)

	var end_title := Label.new()
	end_title.text = "P0.2 — DISCOVERY LOOP"
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_title.add_theme_font_size_override("font_size", 25)
	end_panel.add_child(end_title)

	network_button = Button.new()
	network_button.text = "CARI ORANG YANG TAHU"
	network_button.custom_minimum_size = Vector2(280, 66)
	network_button.visible = false
	network_button.pressed.connect(_go_to_network)
	end_panel.add_child(network_button)

	var restart := Button.new()
	restart.text = "MAIN DARI AWAL"
	restart.custom_minimum_size = Vector2(240, 66)
	restart.pressed.connect(_restart)
	end_panel.add_child(restart)

func _show_entry() -> void:
	var result: Dictionary = AuctionState.lot_results.get("lot02", {})
	if str(result.get("winner", "")) != "mc":
		intro_label.text = "Kamu tidak memiliki Kotak Campuran. Tidak ada barang itu di mejamu untuk diperiksa."
		open_button.visible = false
		observation_label.text = "Discovery hanya boleh memakai barang yang benar-benar kamu miliki."
		note_label.text = "Ulangi sesi dan menangkan Lot 02 untuk menguji P0.2."
		end_panel.visible = true
		return

	var lot_data: Dictionary = data.get("lot02", {})
	intro_label.text = str(lot_data.get("intro", "Kotak Campuran ada di depanmu."))
	observation_label.text = "Di ruang lelang kamu hanya melihat permukaannya."
	note_label.text = "Belum ada catatan baru."

func _open_box() -> void:
	open_button.visible = false
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

	observation_label.text = "Tiga benda paling jelas bisa diperiksa tanpa alat khusus."
	note_label.text = "Pilih salah satu."

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

	if inspect_count >= 2:
		target_panel.visible = true

func _choose_target(target_id: String) -> void:
	target_panel.visible = false
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
