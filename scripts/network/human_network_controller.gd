extends Control

const NETWORK_DATA_PATH := "res://data/network/prototype_network.json"

var data: Dictionary = {}
var target_id: String = ""
var current_location_id: String = "pintu_pasar"
var current_contact_id: String = ""

@onready var target_label: Label = $Margin/Scroll/Root/TargetPanel/TargetMargin/TargetStack/TargetLabel
@onready var note_label: Label = $Margin/Scroll/Root/TargetPanel/TargetMargin/TargetStack/NoteLabel
@onready var location_label: Label = $Margin/Scroll/Root/LocationPanel/LocationMargin/LocationStack/LocationLabel
@onready var location_description: Label = $Margin/Scroll/Root/LocationPanel/LocationMargin/LocationStack/LocationDescription
@onready var response_label: Label = $Margin/Scroll/Root/ResponsePanel/ResponseMargin/ResponseLabel
@onready var status_label: Label = $Margin/Scroll/Root/StatusPanel/StatusMargin/StatusLabel
@onready var travel_label: Label = $Margin/Scroll/Root/HeaderPanel/HeaderMargin/HeaderStack/TravelLabel
@onready var map_row: GridContainer = $Margin/Scroll/Root/MapPanel/MapMargin/MapRow
@onready var contact_button: Button = $Margin/Scroll/Root/ContactButton
@onready var finish_button: Button = $Margin/Scroll/Root/FinishButton
@onready var end_panel: VBoxContainer = $Margin/Scroll/Root/EndPanel
@onready var restart_button: Button = $Margin/Scroll/Root/EndPanel/RestartButton

var location_buttons: Dictionary = {}

func _ready() -> void:
	_load_data()
	target_id = AuctionState.discovery_target
	if target_id.is_empty():
		target_id = "unsure"

	if AuctionState.network_known_contacts.is_empty():
		AuctionState.network_known_contacts["pak_wira"] = true

	_wire_ui()
	_show_target()
	_show_location("pintu_pasar", false)

func _wire_ui() -> void:
	location_buttons = {
		"pintu_pasar": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/PintuPasarButton,
		"kios_tengah": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/KiosTengahButton,
		"gang_timur": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/GangTimurButton,
		"lorong_belakang": $Margin/Scroll/Root/MapPanel/MapMargin/MapRow/LorongBelakangButton
	}

	for location_id in location_buttons.keys():
		var button: Button = location_buttons[location_id]
		var captured_id := str(location_id)
		button.pressed.connect(func(): _travel_to(captured_id))

	contact_button.pressed.connect(_talk_here)
	finish_button.pressed.connect(_finish)
	restart_button.pressed.connect(_restart)
	_refresh_map_buttons()
	_refresh_travel_label()

func _load_data() -> void:
	if not FileAccess.file_exists(NETWORK_DATA_PATH):
		push_error("Network data not found: %s" % NETWORK_DATA_PATH)
		return

	var file := FileAccess.open(NETWORK_DATA_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		data = parsed
	else:
		push_error("Network data is invalid JSON.")


func _show_target() -> void:
	target_label.text = "PERTANYAAN: %s" % _target_name(target_id)

	if target_id == "unsure":
		note_label.text = "Kamu belum tahu bagian mana yang paling penting. Pak Slamet cuma menyuruhmu mencari Pak Wira di deretan kios tengah Pasar Tua."
		return

	var note_data: Dictionary = AuctionState.discovery_notes.get(target_id, {})
	var note := str(note_data.get("note", "Belum ada catatan."))
	note_label.text = "Catatan sementara: %s\nPetunjuk awal: Pak Wira biasa di deretan kios tengah." % note

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

	location_label.text = str(location.get("label", location_id)).to_upper()
	location_description.text = str(location.get("description", ""))
	response_label.text = ""
	status_label.text = ""
	finish_button.visible = not AuctionState.network_history.is_empty()

	current_contact_id = str(location.get("contact", ""))
	if current_contact_id.is_empty():
		contact_button.visible = false
	else:
		contact_button.visible = true
		if AuctionState.network_known_contacts.has(current_contact_id):
			contact_button.text = "BICARA DENGAN %s" % _contact_name(current_contact_id).to_upper()
		else:
			contact_button.text = "TANYA ORANG DI SINI"

	if moved:
		response_label.text = "Kamu berjalan ke %s." % str(location.get("label", location_id))

	_refresh_map_buttons()
	_refresh_travel_label()

func _talk_here() -> void:
	if current_contact_id.is_empty():
		return

	var contacts: Dictionary = data.get("contacts", {})
	var contact: Dictionary = contacts.get(current_contact_id, {})
	if contact.is_empty():
		return

	var first_time := not AuctionState.network_known_contacts.has(current_contact_id)
	if first_time:
		AuctionState.network_known_contacts[current_contact_id] = true
		response_label.text = str(contact.get("first_meet", "Kamu berkenalan."))
	else:
		response_label.text = str(contact.get("profile", ""))

	var responses: Dictionary = contact.get("responses", {})
	var response: Dictionary = responses.get(target_id, {})
	if response.is_empty():
		status_label.text = "Dia tidak punya konteks untuk pertanyaan ini."
		_refresh_map_buttons()
		return

	var response_text := str(response.get("text", ""))
	if first_time and not response_label.text.is_empty():
		response_label.text += "\n\n" + response_text
	else:
		response_label.text = response_text

	var status := str(response.get("status", "outside_field"))
	var referral := str(response.get("referral", ""))
	var referral_location := str(response.get("referral_location", ""))

	AuctionState.network_history.append({
		"target": target_id,
		"contact": current_contact_id,
		"location": current_location_id,
		"status": status,
		"travel_steps": AuctionState.network_travel_steps
	})

	match status:
		"context":
			var finding := str(response.get("finding", ""))
			AuctionState.network_finding = finding
			status_label.text = "KONTEKS BARU\n%s" % finding
		"referral":
			if not referral.is_empty():
				AuctionState.network_known_contacts[referral] = true
			status_label.text = "PETUNJUK BARU: %s — %s. Kamu tetap harus mencarinya di peta." % [
				_contact_name(referral),
				_location_name(referral_location)
			]
		"network_gap":
			status_label.text = "JARINGAN GAP — orang yang tepat belum ada dalam jaringanmu."
		"framing":
			status_label.text = "PERTANYAAN TERLALU LUAS — kamu perlu mempersempit apa yang ingin diketahui."
		"outside_field":
			status_label.text = "BATAS PENGETAHUAN — ini bukan bidangnya."
		_:
			status_label.text = "Informasi belum cukup."

	finish_button.visible = true
	_refresh_map_buttons()

func _refresh_map_buttons() -> void:
	var locations: Dictionary = data.get("locations", {})
	for location_id in location_buttons.keys():
		var button: Button = location_buttons[location_id]
		var location: Dictionary = locations.get(location_id, {})
		var label := str(location.get("label", location_id)).to_upper()
		var contact_id := str(location.get("contact", ""))

		if not contact_id.is_empty() and AuctionState.network_known_contacts.has(contact_id):
			label += "\n%s?" % _contact_name(contact_id)

		if location_id == current_location_id:
			label = "• " + label
			button.theme_type_variation = &"SelectedButton"
		else:
			button.theme_type_variation = &""

		button.text = label

func _refresh_travel_label() -> void:
	travel_label.text = "Langkah perjalanan: %d" % AuctionState.network_travel_steps

func _finish() -> void:
	map_row.visible = false
	contact_button.visible = false
	finish_button.visible = false
	end_panel.visible = true

	if not AuctionState.network_finding.is_empty():
		status_label.text = "Yang berubah bukan barangnya. Yang berubah adalah apa yang sekarang kamu tahu."
	elif target_id == "adapter":
		status_label.text = "Tidak ada jawaban final. Jaringanmu perlu bertambah."
	elif target_id == "unsure":
		status_label.text = "Kamu belajar bahwa mencari orang yang tepat dimulai dari membuat pertanyaan yang tepat."
	else:
		status_label.text = "Konteks masih belum lengkap. Itu bukan kegagalan."

	status_label.text += "\nPerjalanan dilakukan: %d langkah." % AuctionState.network_travel_steps

func _target_name(id: String) -> String:
	match id:
		"coaster":
			return "TATAKAN"
		"lighter":
			return "KOREK MEJA"
		"adapter":
			return "ADAPTOR"
		"unsure":
			return "BELUM YAKIN"
		_:
			return id.to_upper()

func _contact_name(id: String) -> String:
	var contacts: Dictionary = data.get("contacts", {})
	var contact: Dictionary = contacts.get(id, {})
	return str(contact.get("display_name", id))

func _location_name(id: String) -> String:
	var locations: Dictionary = data.get("locations", {})
	var location: Dictionary = locations.get(id, {})
	return str(location.get("label", id))

func _restart() -> void:
	AuctionState.reset_prototype()
	get_tree().change_scene_to_file("res://scenes/auction/auction_room.tscn")
