extends Control

const NETWORK_DATA_PATH := "res://data/network/prototype_network.json"

var data: Dictionary = {}
var target_id: String = ""
var current_referral: String = ""

var target_label: Label
var note_label: Label
var response_label: Label
var status_label: Label
var contact_row: HBoxContainer
var referral_button: Button
var finish_button: Button
var end_panel: VBoxContainer

func _ready() -> void:
	_load_data()
	target_id = AuctionState.discovery_target
	if target_id.is_empty():
		target_id = "unsure"
	_build_ui()
	_show_target()

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

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#1b1714")
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

	var title := Label.new()
	title.text = "JARINGAN ORANG — PROTOTYPE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 29)
	root.add_child(title)

	var principle := Label.new()
	principle.text = "Buku memberi fragmen. Manusia memberi konteks."
	principle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	principle.add_theme_font_size_override("font_size", 18)
	root.add_child(principle)

	target_label = Label.new()
	target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	target_label.add_theme_font_size_override("font_size", 23)
	root.add_child(target_label)

	note_label = Label.new()
	note_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_label.custom_minimum_size = Vector2(0, 105)
	note_label.add_theme_font_size_override("font_size", 17)
	root.add_child(note_label)

	var prompt := Label.new()
	prompt.text = "Kamu mau bertanya kepada siapa?"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 19)
	root.add_child(prompt)

	contact_row = HBoxContainer.new()
	contact_row.alignment = BoxContainer.ALIGNMENT_CENTER
	contact_row.add_theme_constant_override("separation", 10)
	root.add_child(contact_row)

	for contact in [
		{"id":"pak_wira","label":"PAK WIRA\nJARINGAN"},
		{"id":"bu_sari","label":"BU SARI\nLOGAM"},
		{"id":"yanto","label":"YANTO\nMEKANISME"}
	]:
		var button := Button.new()
		button.text = contact.label
		button.custom_minimum_size = Vector2(190, 80)
		var contact_id: String = contact.id
		button.pressed.connect(func(): _ask_contact(contact_id))
		contact_row.add_child(button)

	response_label = Label.new()
	response_label.text = "Belum ada yang ditanya."
	response_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	response_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response_label.custom_minimum_size = Vector2(0, 230)
	response_label.add_theme_font_size_override("font_size", 19)
	root.add_child(response_label)

	status_label = Label.new()
	status_label.text = ""
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(0, 90)
	status_label.add_theme_font_size_override("font_size", 18)
	root.add_child(status_label)

	referral_button = Button.new()
	referral_button.visible = false
	referral_button.custom_minimum_size = Vector2(270, 66)
	referral_button.pressed.connect(_follow_referral)
	root.add_child(referral_button)

	finish_button = Button.new()
	finish_button.text = "AKHIRI P0.3"
	finish_button.visible = false
	finish_button.custom_minimum_size = Vector2(240, 66)
	finish_button.pressed.connect(_finish)
	root.add_child(finish_button)

	end_panel = VBoxContainer.new()
	end_panel.visible = false
	end_panel.add_theme_constant_override("separation", 12)
	root.add_child(end_panel)

	var end_title := Label.new()
	end_title.text = "P0.3 — HUMAN NETWORK"
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_title.add_theme_font_size_override("font_size", 25)
	end_panel.add_child(end_title)

	var end_copy := Label.new()
	end_copy.text = "Jaringan bukan daftar NPC serba tahu. Nilainya ada pada siapa yang tahu apa — dan siapa yang tahu harus bertanya kepada siapa."
	end_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_copy.add_theme_font_size_override("font_size", 18)
	end_panel.add_child(end_copy)

	var restart := Button.new()
	restart.text = "MAIN DARI AWAL"
	restart.custom_minimum_size = Vector2(240, 66)
	restart.pressed.connect(_restart)
	end_panel.add_child(restart)

func _show_target() -> void:
	target_label.text = "PERTANYAAN: %s" % _target_name(target_id)

	if target_id == "unsure":
		note_label.text = "Kamu tahu ada sesuatu yang perlu dipahami, tapi belum bisa merumuskan bagian mana."
		return

	var note_data: Dictionary = AuctionState.discovery_notes.get(target_id, {})
	var note := str(note_data.get("note", "Belum ada catatan."))
	note_label.text = "Catatan sementara: %s" % note

func _ask_contact(contact_id: String) -> void:
	var contacts: Dictionary = data.get("contacts", {})
	var contact: Dictionary = contacts.get(contact_id, {})
	var responses: Dictionary = contact.get("responses", {})
	var response: Dictionary = responses.get(target_id, {})

	if response.is_empty():
		response_label.text = "%s tidak punya respons untuk pertanyaan ini." % str(contact.get("display_name", contact_id))
		status_label.text = "Prototype data belum lengkap."
		return

	var text := str(response.get("text", ""))
	var status := str(response.get("status", "outside_field"))
	current_referral = str(response.get("referral", ""))

	response_label.text = text
	AuctionState.network_history.append({
		"target": target_id,
		"contact": contact_id,
		"status": status
	})

	referral_button.visible = false
	finish_button.visible = true

	match status:
		"context":
			var finding := str(response.get("finding", ""))
			AuctionState.network_finding = finding
			status_label.text = "KONTEKS BARU\n%s" % finding
		"referral":
			status_label.text = "Dia tidak memberi jawaban final, tetapi memberi rujukan."
			if not current_referral.is_empty():
				referral_button.text = "TEMUI %s" % _contact_name(current_referral).to_upper()
				referral_button.visible = true
		"network_gap":
			status_label.text = "JARINGAN GAP — orang yang tepat belum ada di jaringanmu."
		"framing":
			status_label.text = "PERTANYAAN TERLALU LUAS — kamu perlu mempersempit apa yang ingin diketahui."
		"outside_field":
			status_label.text = "BATAS PENGETAHUAN — ini bukan bidangnya."
		_:
			status_label.text = "Informasi belum cukup."

func _follow_referral() -> void:
	if current_referral.is_empty():
		return
	_ask_contact(current_referral)

func _finish() -> void:
	contact_row.visible = false
	referral_button.visible = false
	finish_button.visible = false
	end_panel.visible = true

	if not AuctionState.network_finding.is_empty():
		status_label.text = "Yang berubah bukan barangnya. Yang berubah adalah apa yang sekarang kamu tahu."
	elif target_id == "adapter":
		status_label.text = "Tidak ada jawaban final. Jaringanmu perlu bertambah."
	elif target_id == "unsure":
		status_label.text = "Sebelum mencari ahli, kamu perlu belajar membuat pertanyaan yang lebih tajam."
	else:
		status_label.text = "Konteks masih belum lengkap. Itu bukan kegagalan."

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

func _restart() -> void:
	AuctionState.reset_prototype()
	get_tree().change_scene_to_file("res://scenes/auction/auction_room.tscn")
