extends Control

const DATA_PATH := "res://data/chapter/chapter3_orang_yang_tepat.json"

var data: Dictionary = {}
var current_location_id: String = "pintu_pasar"
var current_contact_id: String = ""
var owns_box: bool = false
var target_id: String = ""

var title_label: Label
var subtitle_label: Label
var map_row: GridContainer
var location_label: Label
var location_description: Label
var response_label: Label
var book_label: Label
var travel_label: Label
var contact_button: Button
var poster_button: Button
var finish_button: Button
var location_buttons: Dictionary = {}

func _ready() -> void:
	AuctionState.start_chapter3()
	AuctionState.network_known_contacts["pak_wira"] = true
	owns_box = _owns_lot02()
	target_id = AuctionState.discovery_target
	_load_data()
	_build_ui()
	_show_intro()

func _load_data() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		push_error("Chapter 3 data not found: %s" % DATA_PATH)
		return

	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		data = parsed
	else:
		push_error("Chapter 3 data invalid.")

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#1b1714")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 11)
	margin.add_child(root)

	title_label = Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.text = "BAB 3 — ORANG YANG TEPAT"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	root.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 17)
	root.add_child(subtitle_label)

	travel_label = Label.new()
	travel_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	travel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	travel_label.add_theme_font_size_override("font_size", 16)
	root.add_child(travel_label)

	map_row = GridContainer.new()
	map_row.columns = 2
	map_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_row.add_theme_constant_override("h_separation", 8)
	map_row.add_theme_constant_override("v_separation", 8)
	root.add_child(map_row)

	var order := ["pintu_pasar", "kios_tengah", "kedai_pojok", "gang_timur", "lorong_belakang", "papan_pengumuman"]
	for location_id in order:
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 62)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var captured_id: String = location_id
		button.pressed.connect(func(): _travel_to(captured_id))
		map_row.add_child(button)
		location_buttons[location_id] = button

	location_label = Label.new()
	location_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_label.add_theme_font_size_override("font_size", 23)
	root.add_child(location_label)

	location_description = Label.new()
	location_description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	location_description.custom_minimum_size = Vector2(0, 105)
	location_description.add_theme_font_size_override("font_size", 17)
	root.add_child(location_description)

	contact_button = Button.new()
	contact_button.visible = false
	contact_button.custom_minimum_size = Vector2(280, 62)
	contact_button.pressed.connect(_talk_here)
	root.add_child(contact_button)

	response_label = Label.new()
	response_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	response_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	response_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response_label.custom_minimum_size = Vector2(0, 190)
	response_label.add_theme_font_size_override("font_size", 18)
	root.add_child(response_label)

	book_label = Label.new()
	book_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	book_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	book_label.custom_minimum_size = Vector2(0, 125)
	book_label.add_theme_font_size_override("font_size", 16)
	root.add_child(book_label)

	poster_button = Button.new()
	poster_button.visible = false
	poster_button.custom_minimum_size = Vector2(280, 62)
	poster_button.pressed.connect(_poster_action)
	root.add_child(poster_button)

	finish_button = Button.new()
	finish_button.text = "SELESAIKAN BAB 3"
	finish_button.visible = false
	finish_button.custom_minimum_size = Vector2(280, 66)
	finish_button.pressed.connect(_finish_chapter)
	root.add_child(finish_button)

	_refresh_map_buttons()
	_refresh_travel()

func _show_intro() -> void:
	if owns_box:
		subtitle_label.text = "%s dari Kotak Campuran masih menyisakan pertanyaan. Buku hanya punya fragmen; kamu butuh orang yang tepat." % _target_label(target_id)
	else:
		subtitle_label.text = "Kamu tidak membawa Kotak Campuran pulang. Yang bisa dibangun sekarang bukan appraisal palsu, tetapi jaringan orang yang mungkin berguna nanti."

	_show_location("pintu_pasar", false)
	response_label.text = "Pak Slamet pernah menyebut satu nama: Pak Wira. Katanya ia sering ada di deretan kios tengah Pasar Tua."
	book_label.text = "BUKU — belum ada orang baru dicatat."

func _travel_to(location_id: String) -> void:
	if location_id == current_location_id:
		_show_location(location_id, false)
		return

	AuctionState.network_travel_steps += 1
	_show_location(location_id, true)

func _show_location(location_id: String, moved: bool) -> void:
	var locations: Dictionary = data.get("locations", {})
	var location: Dictionary = locations.get(location_id, {})
	if location.is_empty():
		return

	current_location_id = location_id
	AuctionState.network_visited_locations[location_id] = true
	current_contact_id = str(location.get("contact", ""))

	location_label.text = str(location.get("label", location_id)).to_upper()
	location_description.text = str(location.get("description", ""))
	if moved:
		response_label.text = "Kamu berjalan ke %s." % str(location.get("label", location_id))
	else:
		response_label.text = ""

	if current_location_id == "papan_pengumuman" and not _network_complete():
		location_description.text = "Papan tua dekat pintu keluar. Ada iklan servis, kehilangan barang, dan pengumuman lama. Belum ada sesuatu yang cukup membuatmu berhenti."
	elif current_location_id == "papan_pengumuman" and _network_complete():
		location_description.text = "Papan tua dekat pintu keluar tampak sedikit berbeda dari saat kamu datang. Ada satu poster baru menutup sebagian kertas lama."

	if current_contact_id.is_empty():
		contact_button.visible = false
	else:
		contact_button.visible = true
		if AuctionState.chapter3_people_book.has(current_contact_id):
			contact_button.text = "BICARA LAGI DENGAN %s" % _person_name(current_contact_id).to_upper()
		else:
			contact_button.text = "TANYA ORANG DI SINI"

	if current_location_id == "papan_pengumuman" and _network_complete():
		poster_button.visible = true
		poster_button.text = "PERIKSA PAPAN"
	else:
		poster_button.visible = false

	_refresh_map_buttons()
	_refresh_travel()
	_refresh_book()

func _talk_here() -> void:
	if current_contact_id.is_empty():
		return

	var people: Dictionary = data.get("people", {})
	var person: Dictionary = people.get(current_contact_id, {})
	if person.is_empty():
		return

	var first_time := not AuctionState.chapter3_people_book.has(current_contact_id)
	var lines: Array[String] = []

	if first_time:
		lines.append(str(person.get("first_meet", "")))
		AuctionState.record_chapter3_person(
			current_contact_id,
			str(person.get("book_note", ""))
		)

	var next_person := ""
	var next_location := ""
	if owns_box:
		var responses: Dictionary = person.get("responses", {})
		var response: Dictionary = responses.get(target_id, {})
		if response.is_empty():
			lines.append("Orang ini belum punya konteks yang cocok untuk benda yang kamu pilih.")
		else:
			lines.append(str(response.get("text", "")))
			var extra := str(response.get("next_text", ""))
			if not extra.is_empty():
				lines.append(extra)

			var finding := str(response.get("finding", ""))
			if not finding.is_empty():
				AuctionState.network_finding = finding
				AuctionState.chapter3_context_found = true

			next_person = str(response.get("next_person", ""))
			next_location = str(response.get("next_location", ""))
	else:
		lines.append(str(person.get("without_box", "")))
		next_person = str(person.get("next_person", ""))
		next_location = str(person.get("next_location", ""))

	if not next_person.is_empty():
		AuctionState.network_known_contacts[next_person] = true

	response_label.text = "\n\n".join(lines)

	_refresh_book()
	_refresh_map_buttons()

	if current_location_id == "papan_pengumuman" and _network_complete():
		poster_button.visible = true
		poster_button.text = "PERIKSA PAPAN"
	else:
		poster_button.visible = false

func _network_complete() -> bool:
	for person_id in _required_people():
		if not AuctionState.chapter3_people_book.has(person_id):
			return false
	return true

func _required_people() -> Array[String]:
	if not owns_box:
		return ["pak_wira", "pak_damar", "bu_sari", "yanto"]

	match target_id:
		"coaster":
			return ["pak_wira", "pak_damar", "bu_sari"]
		"lighter":
			return ["pak_wira", "pak_damar", "yanto"]
		"adapter":
			return ["pak_wira", "pak_damar"]
		_:
			return ["pak_wira", "pak_damar"]

func _poster_action() -> void:
	if current_location_id != "papan_pengumuman":
		return
	_show_poster()

func _show_poster() -> void:
	AuctionState.chapter3_poster_seen = true
	map_row.visible = false
	contact_button.visible = false
	poster_button.visible = false

	var poster: Dictionary = data.get("poster", {})
	title_label.text = str(poster.get("title", "SENTANA PRIVATE AUCTION"))
	location_label.text = "PAPAN PENGUMUMAN"
	location_description.text = str(poster.get("body", ""))
	response_label.text = str(poster.get("action", "Kamu memotret poster itu."))
	book_label.text = "Syarat masuk: %s" % str(poster.get("requirement", "INVITE REQUIRED"))

	if AuctionState.chapter2_route == "B3B_CHASE_TOO_LONG":
		response_label.text = "Nama yang sama.\n\n" + response_label.text

	AuctionState.chapter3_poster_photographed = true
	finish_button.visible = true

func _finish_chapter() -> void:
	if AuctionState.chapter3_complete:
		get_tree().change_scene_to_file("res://scenes/chapter/chapter1_intro.tscn")
		return

	AuctionState.finish_chapter3()
	title_label.text = "BAB 3 SELESAI"
	subtitle_label.text = "ORANG YANG TEPAT"
	location_label.text = ""
	location_description.text = ""
	response_label.text = "Pengetahuan tidak tinggal di satu orang. Kamu pulang dengan empat nama, beberapa batas pengetahuan, dan satu foto undangan yang belum bisa kamu masuki."

	if owns_box and AuctionState.chapter3_context_found:
		book_label.text = "BUKU — %s: %s\nPoster: SENTANA PRIVATE AUCTION — INVITE REQUIRED." % [
			_target_label(target_id),
			AuctionState.network_finding
		]
	else:
		book_label.text = "BUKU — jaringan bertambah. Poster: SENTANA PRIVATE AUCTION — INVITE REQUIRED."

	finish_button.text = "MAIN DARI AWAL"
	finish_button.visible = true

func _refresh_map_buttons() -> void:
	var locations: Dictionary = data.get("locations", {})
	for location_id in location_buttons.keys():
		var button: Button = location_buttons[location_id]
		var location: Dictionary = locations.get(location_id, {})
		var label := str(location.get("label", location_id)).to_upper()
		var contact_id := str(location.get("contact", ""))

		if location_id == current_location_id:
			label = "• " + label

		button.text = label

func _refresh_book() -> void:
	if AuctionState.chapter3_people_book.is_empty():
		book_label.text = "BUKU — belum ada orang baru dicatat."
		return

	var lines: Array[String] = ["BUKU — ORANG"]
	for person_id in ["pak_wira", "pak_damar", "bu_sari", "yanto"]:
		if AuctionState.chapter3_people_book.has(person_id):
			lines.append("• %s" % str(AuctionState.chapter3_people_book[person_id]))
	book_label.text = "\n".join(lines)

func _refresh_travel() -> void:
	travel_label.text = "Perpindahan lokasi: %d" % AuctionState.network_travel_steps

func _person_name(person_id: String) -> String:
	var people: Dictionary = data.get("people", {})
	var person: Dictionary = people.get(person_id, {})
	return str(person.get("name", person_id))

func _location_name(location_id: String) -> String:
	var locations: Dictionary = data.get("locations", {})
	var location: Dictionary = locations.get(location_id, {})
	return str(location.get("label", location_id))

func _target_label(id: String) -> String:
	match id:
		"coaster":
			return "Tatakan"
		"lighter":
			return "Korek meja"
		"adapter":
			return "Adaptor"
		_:
			return "Barang pilihanmu"

func _owns_lot02() -> bool:
	var result: Dictionary = AuctionState.lot_results.get("lot02", {})
	return str(result.get("winner", "")) == "mc"
