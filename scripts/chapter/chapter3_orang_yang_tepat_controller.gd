extends Control

const DATA_PATH := "res://data/chapter/chapter3_orang_yang_tepat.json"

var data: Dictionary = {}
var current_location_id: String = "pintu_pasar"
var current_contact_id: String = ""

var title_label: Label
var subtitle_label: Label
var inventory_grid: GridContainer
var inventory_detail: Label
var map_row: GridContainer
var location_label: Label
var location_description: Label
var response_label: Label
var book_label: Label
var travel_label: Label
var contact_button: Button
var show_item_button: Button
var poster_button: Button
var wait_button: Button
var exit_button: Button
var location_buttons: Dictionary = {}

func _ready() -> void:
	AuctionState.start_chapter3()
	_load_data()
	_build_ui()
	_show_location("pintu_pasar", false)
	response_label.text = "Pasar ramai seperti biasa. Tidak ada penanda yang menunjukkan siapa yang harus kamu cari."
	_refresh_inventory()
	_refresh_book()

func _load_data() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		push_error("Pasar Tua data not found: %s" % DATA_PATH)
		return

	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		data = parsed
	else:
		push_error("Pasar Tua data invalid.")

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#1b1714")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	title_label = Label.new()
	title_label.text = "PASAR TUA"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 27)
	root.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "Pilih tempat. Coba barang. Dengarkan orang."
	subtitle_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 15)
	root.add_child(subtitle_label)

	travel_label = Label.new()
	travel_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	travel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	travel_label.add_theme_font_size_override("font_size", 14)
	root.add_child(travel_label)

	var inv_title := Label.new()
	inv_title.text = "INVENTORY"
	inv_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inv_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inv_title.add_theme_font_size_override("font_size", 16)
	root.add_child(inv_title)

	inventory_grid = GridContainer.new()
	inventory_grid.columns = 2
	inventory_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_grid.add_theme_constant_override("h_separation", 7)
	inventory_grid.add_theme_constant_override("v_separation", 7)
	root.add_child(inventory_grid)

	inventory_detail = Label.new()
	inventory_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_detail.custom_minimum_size = Vector2(0, 95)
	inventory_detail.add_theme_font_size_override("font_size", 15)
	root.add_child(inventory_detail)

	map_row = GridContainer.new()
	map_row.columns = 2
	map_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_row.add_theme_constant_override("h_separation", 8)
	map_row.add_theme_constant_override("v_separation", 8)
	root.add_child(map_row)

	var order := [
		"pintu_pasar",
		"kios_tengah",
		"kedai_pojok",
		"gang_timur",
		"lorong_belakang",
		"papan_pengumuman"
	]

	for location_id in order:
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 56)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var captured_id: String = location_id
		button.pressed.connect(func(): _travel_to(captured_id))
		map_row.add_child(button)
		location_buttons[location_id] = button

	location_label = Label.new()
	location_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_label.add_theme_font_size_override("font_size", 21)
	root.add_child(location_label)

	location_description = Label.new()
	location_description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	location_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	location_description.custom_minimum_size = Vector2(0, 90)
	location_description.add_theme_font_size_override("font_size", 16)
	root.add_child(location_description)

	contact_button = Button.new()
	contact_button.visible = false
	contact_button.custom_minimum_size = Vector2(0, 56)
	contact_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contact_button.pressed.connect(_talk_here)
	root.add_child(contact_button)

	show_item_button = Button.new()
	show_item_button.text = "TUNJUKKAN BARANG"
	show_item_button.visible = false
	show_item_button.custom_minimum_size = Vector2(0, 56)
	show_item_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	show_item_button.pressed.connect(_show_item_here)
	root.add_child(show_item_button)

	poster_button = Button.new()
	poster_button.text = "PERIKSA PAPAN"
	poster_button.visible = false
	poster_button.custom_minimum_size = Vector2(0, 56)
	poster_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	poster_button.pressed.connect(_inspect_notice_board)
	root.add_child(poster_button)

	wait_button = Button.new()
	wait_button.text = "DUDUK SEBENTAR"
	wait_button.custom_minimum_size = Vector2(0, 50)
	wait_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wait_button.pressed.connect(_wait_market)
	root.add_child(wait_button)

	exit_button = Button.new()
	exit_button.text = "KELUAR PASAR"
	exit_button.custom_minimum_size = Vector2(0, 56)
	exit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exit_button.pressed.connect(_exit_market)
	root.add_child(exit_button)

	response_label = Label.new()
	response_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	response_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	response_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response_label.custom_minimum_size = Vector2(0, 145)
	response_label.add_theme_font_size_override("font_size", 17)
	root.add_child(response_label)

	book_label = Label.new()
	book_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	book_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	book_label.custom_minimum_size = Vector2(0, 110)
	book_label.add_theme_font_size_override("font_size", 15)
	root.add_child(book_label)

	_refresh_map_buttons()
	_refresh_travel()

func _travel_to(location_id: String) -> void:
	if location_id == current_location_id:
		_show_location(location_id, false)
		return

	AuctionState.network_travel_steps += 1
	AuctionState.advance_chapter2_time(10)
	_show_location(location_id, true)
	_check_world_deadline()

func _show_location(location_id: String, moved: bool) -> void:
	var locations: Dictionary = data.get("locations", {})
	var location: Dictionary = locations.get(location_id, {})
	if location.is_empty():
		return

	current_location_id = location_id
	AuctionState.network_visited_locations[location_id] = true

	var scheduled_contact := str(location.get("contact", ""))
	current_contact_id = scheduled_contact if _is_contact_present(scheduled_contact) else ""

	location_label.text = str(location.get("label", location_id)).to_upper()
	location_description.text = str(location.get("description", ""))

	if current_location_id == "papan_pengumuman":
		if _poster_available():
			location_description.text = "Papan pengumuman penuh kertas lama. Satu poster baru menutup sebagian iklan servis."
		else:
			location_description.text = "Papan pengumuman berisi iklan servis, kehilangan barang, dan kertas lama."

	var absent_text := ""
	if not scheduled_contact.is_empty() and current_contact_id.is_empty():
		absent_text = _contact_absent_text(scheduled_contact)

	if moved:
		response_label.text = "Kamu berjalan ke %s." % str(location.get("label", location_id))
		if not absent_text.is_empty():
			response_label.text += "\n\n" + absent_text
	elif not absent_text.is_empty():
		response_label.text = absent_text
	else:
		response_label.text = ""

	contact_button.visible = not current_contact_id.is_empty()
	if contact_button.visible:
		if AuctionState.chapter3_people_book.has(current_contact_id):
			contact_button.text = "BICARA LAGI"
		else:
			contact_button.text = "BICARA"

	show_item_button.visible = (
		not current_contact_id.is_empty()
		and not AuctionState.selected_inventory_item.is_empty()
		and AuctionState.has_inventory_item(AuctionState.selected_inventory_item)
	)

	poster_button.visible = current_location_id == "papan_pengumuman" and _poster_available()
	wait_button.visible = current_location_id in ["pintu_pasar", "kedai_pojok"]

	_refresh_map_buttons()
	_refresh_travel()
	_refresh_inventory()
	_refresh_book()

func _talk_here() -> void:
	if current_contact_id.is_empty():
		return

	AuctionState.advance_chapter2_time(10)

	var people: Dictionary = data.get("people", {})
	var person: Dictionary = people.get(current_contact_id, {})
	if person.is_empty():
		return

	var first_time := not AuctionState.chapter3_people_book.has(current_contact_id)
	if first_time:
		AuctionState.record_chapter3_person(
			current_contact_id,
			str(person.get("book_note", ""))
		)
		response_label.text = str(person.get("first_meet", "Kamu berkenalan."))
	else:
		response_label.text = str(person.get("name", "Orang itu")) + " masih ada di tempatnya."

	_refresh_book()
	_refresh_inventory()
	_refresh_location_controls()
	_check_world_deadline()

func _show_item_here() -> void:
	if current_contact_id.is_empty():
		return

	AuctionState.advance_chapter2_time(10)

	var item_id := AuctionState.selected_inventory_item
	if item_id.is_empty() or not AuctionState.has_inventory_item(item_id):
		return

	var people: Dictionary = data.get("people", {})
	var person: Dictionary = people.get(current_contact_id, {})
	if person.is_empty():
		return

	var responses: Dictionary = person.get("responses", {})
	var response: Dictionary = responses.get(item_id, {})

	if response.is_empty():
		response_label.text = "Orang itu melihat barangmu sebentar, tetapi tidak punya sesuatu yang berguna untuk dikatakan."
		_refresh_location_controls()
		return

	response_label.text = str(response.get("text", ""))

	var finding := str(response.get("finding", ""))
	if not finding.is_empty():
		AuctionState.network_finding = finding
		AuctionState.discovery_notes[item_id] = {
			"note": finding,
			"status": "context"
		}
		AuctionState.update_inventory_item(item_id, {
			"description": finding
		})

	if bool(response.get("can_open_box", false)) and item_id == "mixed_box":
		AuctionState.open_mixed_box()
		AuctionState.selected_inventory_item = ""
		response_label.text += "\n\nBeberapa menit kemudian, kotaknya terbuka. Isi yang terpisah sekarang masuk ke inventory."

	AuctionState.world_flags["market_interactions"] = int(
		AuctionState.world_flags.get("market_interactions", 0)
	) + 1

	_refresh_inventory()
	_refresh_book()
	_refresh_location_controls()
	_check_world_deadline()

func _refresh_location_controls() -> void:
	show_item_button.visible = (
		not current_contact_id.is_empty()
		and not AuctionState.selected_inventory_item.is_empty()
		and AuctionState.has_inventory_item(AuctionState.selected_inventory_item)
	)
	poster_button.visible = current_location_id == "papan_pengumuman" and _poster_available()
	wait_button.visible = current_location_id in ["pintu_pasar", "kedai_pojok"]

func _poster_available() -> bool:
	if AuctionState.chapter3_poster_photographed:
		return true

	var day := AuctionState.chapter2_day_name()
	var minute_of_day := AuctionState.chapter2_time_minutes % (24 * 60)

	if day == "Minggu":
		return minute_of_day >= 18 * 60 + 30

	return day == "Senin"

func _inspect_notice_board() -> void:
	if current_location_id != "papan_pengumuman":
		return
	if not _poster_available():
		return

	var poster: Dictionary = data.get("poster", {})
	AuctionState.chapter3_poster_seen = true

	if not AuctionState.chapter3_poster_photographed:
		AuctionState.chapter3_poster_photographed = true
		AuctionState.add_inventory_item("sentana_photo", {
			"name": "FOTO POSTER SENTANA",
			"state": "photo",
			"description": "Foto poster bertuliskan SENTANA PRIVATE AUCTION — BY INVITATION ONLY.",
			"source": "Papan Pengumuman Pasar Tua"
		})

	response_label.text = "%s\n\n%s" % [
		str(poster.get("body", "")),
		str(poster.get("action", "Kamu memotretnya."))
	]
	_refresh_inventory()
	_refresh_book()

func _select_inventory_item(item_id: String) -> void:
	AuctionState.selected_inventory_item = item_id
	_refresh_inventory()
	_refresh_location_controls()

func _refresh_inventory() -> void:
	for child in inventory_grid.get_children():
		child.queue_free()

	for item_id in AuctionState.inventory.keys():
		var item: Dictionary = AuctionState.get_inventory_item(str(item_id))
		var button := Button.new()
		button.text = str(item.get("name", str(item_id).to_upper()))
		button.custom_minimum_size = Vector2(0, 46)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var captured_id := str(item_id)
		button.pressed.connect(func(): _select_inventory_item(captured_id))
		inventory_grid.add_child(button)

	var selected := AuctionState.selected_inventory_item
	if selected.is_empty() or not AuctionState.has_inventory_item(selected):
		inventory_detail.text = "Pilih barang kalau ingin mencoba menunjukkannya kepada seseorang."
		return

	var item := AuctionState.get_inventory_item(selected)
	inventory_detail.text = "%s\n%s" % [
		str(item.get("name", selected.to_upper())),
		str(item.get("description", "Belum diketahui."))
	]

func _refresh_book() -> void:
	if AuctionState.chapter3_people_book.is_empty() and AuctionState.discovery_notes.is_empty():
		book_label.text = "BUKU — belum ada catatan baru."
		return

	var lines: Array[String] = ["BUKU"]
	for person_id in AuctionState.chapter3_people_book.keys():
		lines.append("• %s" % str(AuctionState.chapter3_people_book[person_id]))

	for item_id in AuctionState.discovery_notes.keys():
		var note: Dictionary = AuctionState.discovery_notes[item_id]
		var text := str(note.get("note", ""))
		if not text.is_empty():
			lines.append("• %s — %s" % [
				AuctionState.inventory_item_name(str(item_id)),
				text
			])

	if AuctionState.chapter3_poster_photographed:
		lines.append("• Poster Sentana difoto.")

	book_label.text = "\n".join(lines)

func _refresh_map_buttons() -> void:
	var locations: Dictionary = data.get("locations", {})
	for location_id in location_buttons.keys():
		var button: Button = location_buttons[location_id]
		var location: Dictionary = locations.get(location_id, {})
		var label := str(location.get("label", location_id)).to_upper()
		if location_id == current_location_id:
			label = "• " + label
		button.text = label

func _refresh_travel() -> void:
	travel_label.text = "%s %s  |  Perpindahan: %d" % [
		AuctionState.chapter2_day_name(),
		AuctionState.chapter2_clock(),
		AuctionState.network_travel_steps
	]

func _check_world_deadline() -> void:
	if not AuctionState.resolve_kiosk_deadline_if_needed():
		return
	response_label.text += "\n\nDi luar pasar, batas pembayaran kios lewat. Pak Arman menutup kios."
	subtitle_label.text = "Kios sudah ditutup. Kamu tetap bisa melanjutkan aktivitas."

func _wait_market() -> void:
	AuctionState.advance_chapter2_time(30)
	_show_location(current_location_id, false)
	if response_label.text.is_empty():
		response_label.text = "Sekitar setengah jam berlalu."
	else:
		response_label.text = "Sekitar setengah jam berlalu.\n\n" + response_label.text
	_check_world_deadline()

func _is_contact_present(person_id: String) -> bool:
	if person_id.is_empty():
		return false

	var people: Dictionary = data.get("people", {})
	var person: Dictionary = people.get(person_id, {})
	if person.is_empty():
		return false

	var schedule: Dictionary = person.get("schedule", {})
	var windows: Array = schedule.get("windows", [])
	if windows.is_empty():
		return true

	var day := AuctionState.chapter2_day_name()
	var minute_of_day := AuctionState.chapter2_time_minutes % (24 * 60)

	for raw_window in windows:
		if typeof(raw_window) != TYPE_DICTIONARY:
			continue
		var window: Dictionary = raw_window
		if str(window.get("day", "")) != day:
			continue

		var start_minute := int(window.get("start", 0))
		var end_minute := int(window.get("end", 24 * 60))
		if minute_of_day >= start_minute and minute_of_day < end_minute:
			return true

	return false

func _contact_absent_text(person_id: String) -> String:
	var people: Dictionary = data.get("people", {})
	var person: Dictionary = people.get(person_id, {})
	if person.is_empty():
		return ""

	var schedule: Dictionary = person.get("schedule", {})
	return str(schedule.get("absent_text", ""))

func _exit_market() -> void:
	get_tree().change_scene_to_file("res://scenes/chapter/chapter2_batas.tscn")
