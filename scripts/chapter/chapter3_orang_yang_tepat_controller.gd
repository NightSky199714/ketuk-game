extends Control

const DATA_PATH := "res://data/chapter/chapter3_orang_yang_tepat.json"
const ICON_MARKET = preload("res://assets/ui/icons/market.svg")
const ICON_SHOP = preload("res://assets/ui/icons/shop.svg")
const ICON_NOTICE = preload("res://assets/ui/icons/notice.svg")
const ICON_PIN = preload("res://assets/ui/icons/pin.svg")
const ICON_BOOK = preload("res://assets/ui/icons/book.svg")
const ICON_CAMERA = preload("res://assets/ui/icons/camera.svg")
const ICON_BOX = preload("res://assets/ui/icons/box.svg")

var data: Dictionary = {}
var current_location_id: String = "pintu_pasar"
var current_contact_id: String = ""

@onready var title_label: Label = $Margin/Scroll/Root/HeaderPanel/HeaderMargin/HeaderStack/TitleLabel
@onready var subtitle_label: Label = $Margin/Scroll/Root/HeaderPanel/HeaderMargin/HeaderStack/SubtitleLabel
@onready var inventory_grid: GridContainer = $Margin/Scroll/Root/InventoryPanel/InventoryMargin/InventoryStack/InventoryGrid
@onready var inventory_detail: Label = $Margin/Scroll/Root/InventoryPanel/InventoryMargin/InventoryStack/InventoryDetail
@onready var map_row: GridContainer = $Margin/Scroll/Root/MapPanel/MapMargin/MapRow
@onready var location_label: Label = $Margin/Scroll/Root/LocationPanel/LocationMargin/LocationStack/LocationLabel
@onready var location_description: Label = $Margin/Scroll/Root/LocationPanel/LocationMargin/LocationStack/LocationDescription
@onready var response_label: Label = $Margin/Scroll/Root/ResponsePanel/ResponseMargin/ResponseLabel
@onready var book_label: Label = $Margin/Scroll/Root/BookPanel/BookMargin/BookLabel
@onready var travel_label: Label = $Margin/Scroll/Root/HeaderPanel/HeaderMargin/HeaderStack/TravelLabel
@onready var contact_button: Button = $Margin/Scroll/Root/ActionPanel/ActionMargin/ActionStack/ContactButton
@onready var show_item_button: Button = $Margin/Scroll/Root/ActionPanel/ActionMargin/ActionStack/ShowItemButton
@onready var poster_button: Button = $Margin/Scroll/Root/ActionPanel/ActionMargin/ActionStack/PosterButton
@onready var wait_button: Button = $Margin/Scroll/Root/ActionPanel/ActionMargin/ActionStack/WaitButton
@onready var exit_button: Button = $Margin/Scroll/Root/ActionPanel/ActionMargin/ActionStack/ExitButton
@onready var menu_button: Button = $MenuButton
var location_buttons: Dictionary = {}

func _ready() -> void:
	AuctionState.start_chapter3()
	_load_data()
	_wire_ui()
	_show_location("pintu_pasar", false)
	response_label.text = "Pasar ramai. Suara pedagang, alat kerja, dan orang lewat bercampur dari beberapa lorong."
	_refresh_inventory()
	_refresh_book()

func _wire_ui() -> void:
	location_buttons = {
		"pintu_pasar": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/PintuPasarButton,
		"kios_tengah": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/KiosTengahButton,
		"kedai_pojok": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/KedaiPojokButton,
		"gang_timur": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/GangTimurButton,
		"lorong_belakang": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/LorongBelakangButton,
		"papan_pengumuman": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/PapanButton
	}

	var location_icons := {
		"pintu_pasar": ICON_MARKET,
		"kios_tengah": ICON_SHOP,
		"kedai_pojok": ICON_SHOP,
		"gang_timur": ICON_PIN,
		"lorong_belakang": ICON_PIN,
		"papan_pengumuman": ICON_NOTICE
	}

	for location_id in location_buttons.keys():
		var button: Button = location_buttons[location_id]
		button.icon = location_icons.get(str(location_id), ICON_PIN)
		button.add_theme_constant_override("icon_max_width", 22)
		button.expand_icon = true
		var captured_id := str(location_id)
		button.pressed.connect(func(): _travel_to(captured_id))

	contact_button.pressed.connect(_talk_here)
	show_item_button.pressed.connect(_show_item_here)
	poster_button.pressed.connect(_inspect_notice_board)
	wait_button.pressed.connect(_wait_market)
	exit_button.pressed.connect(_exit_market)
	menu_button.pressed.connect(_return_to_menu)

	_refresh_map_buttons()
	_refresh_travel()

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
		and AuctionState.selected_inventory_item != "book"
		and AuctionState.has_inventory_item(AuctionState.selected_inventory_item)
	)

	poster_button.visible = current_location_id == "papan_pengumuman" and _poster_available()
	wait_button.visible = current_location_id in ["pintu_pasar", "kedai_pojok"]

	_refresh_map_buttons()
	_refresh_travel()
	_refresh_inventory()
	_refresh_book()
	_autosave()

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
	_autosave()

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

	var memory_id := "shown_%s" % item_id
	if AuctionState.npc_remembers(current_contact_id, memory_id):
		response_label.text = "%s sudah pernah melihat barang itu. Ia memeriksanya sekilas lagi, tapi tidak menambahkan sesuatu yang baru." % str(person.get("name", "Orang itu"))
		_refresh_location_controls()
		_check_world_deadline()
		return

	var responses: Dictionary = person.get("responses", {})
	var response: Dictionary = responses.get(item_id, {})

	if response.is_empty():
		response_label.text = "Orang itu melihat barangmu sebentar, tetapi tidak punya sesuatu yang berguna untuk dikatakan."
		_refresh_location_controls()
		return

	response_label.text = str(response.get("text", ""))
	AuctionState.remember_npc_event(current_contact_id, memory_id)

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
	_autosave()

func _refresh_location_controls() -> void:
	show_item_button.visible = (
		not current_contact_id.is_empty()
		and not AuctionState.selected_inventory_item.is_empty()
		and AuctionState.selected_inventory_item != "book"
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
	AuctionState.verify_rumor(
		"sentana_name",
		"Nama Sentana benar tercetak pada poster sebuah private auction."
	)
	AuctionState.verify_rumor(
		"sentana_private_auction",
		"SENTANA PRIVATE AUCTION tercantum sebagai acara by invitation only."
	)

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
	_autosave()

func _inventory_icon(item_id: String) -> Texture2D:
	match item_id:
		"book":
			return ICON_BOOK
		"camera":
			return ICON_CAMERA
		_:
			return ICON_BOX

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
		button.custom_minimum_size = Vector2(0, 58)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.icon = _inventory_icon(str(item_id))
		button.add_theme_constant_override("icon_max_width", 24)
		button.expand_icon = true
		button.theme_type_variation = &"SelectedButton" if AuctionState.selected_inventory_item == str(item_id) else &""
		var captured_id := str(item_id)
		button.pressed.connect(func(): _select_inventory_item(captured_id))
		inventory_grid.add_child(button)

	var selected := AuctionState.selected_inventory_item
	if selected.is_empty() or not AuctionState.has_inventory_item(selected):
		inventory_detail.text = "Tidak ada barang yang sedang dipilih."
		return

	if selected == "book":
		inventory_detail.text = "BUKU LAMA\n\n%s" % AuctionState.book_text()
		return

	var item := AuctionState.get_inventory_item(selected)
	inventory_detail.text = "%s\n%s" % [
		str(item.get("name", selected.to_upper())),
		str(item.get("description", "Belum diketahui."))
	]

func _refresh_book() -> void:
	book_label.text = "BUKU\n%s" % AuctionState.book_text()

func _refresh_map_buttons() -> void:
	var locations: Dictionary = data.get("locations", {})
	for location_id in location_buttons.keys():
		var button: Button = location_buttons[location_id]
		var location: Dictionary = locations.get(location_id, {})
		var label := str(location.get("label", location_id)).to_upper()
		if location_id == current_location_id:
			label = "• " + label
			button.theme_type_variation = &"SelectedButton"
		else:
			button.theme_type_variation = &""
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
	_autosave()

func _wait_market() -> void:
	AuctionState.advance_chapter2_time(30)
	_show_location(current_location_id, false)
	if response_label.text.is_empty():
		response_label.text = "Sekitar setengah jam berlalu."
	else:
		response_label.text = "Sekitar setengah jam berlalu.\n\n" + response_label.text
	_check_world_deadline()
	_autosave()

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
	_autosave()
	get_tree().change_scene_to_file("res://scenes/chapter/chapter2_batas.tscn")

func _autosave() -> void:
	SaveManager.save_game("res://scenes/chapter/chapter3_orang_yang_tepat.tscn")

func _return_to_menu() -> void:
	_autosave()
	get_tree().change_scene_to_file("res://scenes/system/main_menu.tscn")
