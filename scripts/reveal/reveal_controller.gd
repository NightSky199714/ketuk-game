extends Control

var main_label: Label
var detail_label: Label
var jaka_label: Label
var ratna_label: Label
var slamet_label: Label
var end_panel: VBoxContainer

func _ready() -> void:
	_build_ui()
	await get_tree().create_timer(0.25).timeout
	await _run_reveal()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#171311")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	add_child(margin)

	var root := VBoxContainer.new()
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 22)
	margin.add_child(root)

	var title := Label.new()
	title.text = "REVEAL — LOT 03"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	root.add_child(title)

	var result: Dictionary = AuctionState.lot_results.get("lot03", {})
	var winner := str(result.get("winner", "none"))
	var ownership := Label.new()
	if winner == "mc":
		ownership.text = "Kamera ada di tanganmu."
	else:
		ownership.text = "Kamera ada di tangan Jaka."
	ownership.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ownership.add_theme_font_size_override("font_size", 20)
	root.add_child(ownership)

	main_label = Label.new()
	main_label.text = ""
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_label.custom_minimum_size = Vector2(0, 180)
	main_label.add_theme_font_size_override("font_size", 29)
	root.add_child(main_label)

	detail_label = Label.new()
	detail_label.text = ""
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.custom_minimum_size = Vector2(0, 130)
	detail_label.add_theme_font_size_override("font_size", 19)
	root.add_child(detail_label)

	var npc_row := HBoxContainer.new()
	npc_row.alignment = BoxContainer.ALIGNMENT_CENTER
	npc_row.add_theme_constant_override("separation", 16)
	root.add_child(npc_row)

	ratna_label = _npc_label("Bu Ratna", "NEUTRAL")
	npc_row.add_child(ratna_label)
	jaka_label = _npc_label("Jaka", "NEUTRAL" if winner == "mc" else "SURPRISED")
	npc_row.add_child(jaka_label)
	slamet_label = _npc_label("Pak Slamet", "NEUTRAL")
	npc_row.add_child(slamet_label)

	end_panel = VBoxContainer.new()
	end_panel.visible = false
	end_panel.add_theme_constant_override("separation", 14)
	root.add_child(end_panel)

	var end_title := Label.new()
	end_title.text = "P0.1 — AUCTION FEEL SELESAI"
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_title.add_theme_font_size_override("font_size", 28)
	end_panel.add_child(end_title)

	var end_copy := Label.new()
	end_copy.text = "Pertanyaan utamanya: apakah kamu ingin mencoba pilihan yang lain?"
	end_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_copy.add_theme_font_size_override("font_size", 18)
	end_panel.add_child(end_copy)

	var restart := Button.new()
	restart.text = "MAIN LAGI"
	restart.custom_minimum_size = Vector2(240, 68)
	restart.pressed.connect(_restart)
	end_panel.add_child(restart)

func _npc_label(name: String, expression: String) -> Label:
	var label := Label.new()
	label.text = "%s\n[%s]" % [name, expression]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(180, 70)
	label.add_theme_font_size_override("font_size", 16)
	return label

func _run_reveal() -> void:
	main_label.text = "TOK."
	detail_label.text = "Palu jatuh."
	await get_tree().create_timer(1.5).timeout

	main_label.text = "Pak Harun memeriksa body."
	detail_label.text = "Cepat. Seperti tidak ada yang istimewa."
	await get_tree().create_timer(2.2).timeout

	main_label.text = "Body: Rp90.000–Rp150.000."
	detail_label.text = "Beberapa orang mulai tersenyum. Bu Ratna menggeleng pelan."
	ratna_label.text = "Bu Ratna\n[SUSPICIOUS]"
	await get_tree().create_timer(2.4).timeout

	main_label.text = "Pak Harun memutar lensa."
	detail_label.text = ""
	await get_tree().create_timer(2.0).timeout

	main_label.text = "Ia berhenti."
	detail_label.text = ""
	await get_tree().create_timer(1.7).timeout

	main_label.text = "Lensa diangkat ke lampu."
	detail_label.text = "Pak Harun tidak mengatakan apa-apa."
	await get_tree().create_timer(2.8).timeout

	main_label.text = "Kaca pembesar diletakkan."
	detail_label.text = "Ia mengambil lampu lain."
	await get_tree().create_timer(2.5).timeout

	main_label.text = "Ia melihat lagi."
	detail_label.text = ""
	jaka_label.text = "Jaka\n[SUSPICIOUS]"
	await get_tree().create_timer(2.3).timeout

	main_label.text = "Produksi terbatas."
	detail_label.text = "Cincin aperture desain lama. Nomor seri di luar range produksi umum."
	await get_tree().create_timer(3.6).timeout

	main_label.text = "..."
	detail_label.text = ""
	await get_tree().create_timer(1.5).timeout

	main_label.text = "Perkiraan nilai kolektor"
	detail_label.text = "Rp2.800.000 – Rp3.600.000"
	await get_tree().create_timer(4.0).timeout

	main_label.text = ""
	detail_label.text = "Ruangan berhenti."
	ratna_label.text = "Bu Ratna\n[SURPRISED]"
	jaka_label.text = "Jaka\n[NEUTRAL]"
	slamet_label.text = "Pak Slamet\n[INTERESTED]"
	await get_tree().create_timer(1.8).timeout

	main_label.text = "Bu Ratna: \"Lho?\""
	detail_label.text = ""
	await get_tree().create_timer(2.0).timeout

	main_label.text = "Pak Slamet menutup kacamatanya."
	detail_label.text = "Ia meletakkannya di meja."
	await get_tree().create_timer(2.0).timeout

	main_label.text = ""
	detail_label.text = ""
	end_panel.visible = true

func _restart() -> void:
	AuctionState.reset_prototype()
	get_tree().change_scene_to_file("res://scenes/auction/auction_room.tscn")
