extends Control

var title_label: Label
var ownership_label: Label
var main_label: Label
var detail_label: Label
var jaka_label: Label
var ratna_label: Label
var slamet_label: Label
var choice_panel: HBoxContainer
var followup_button: Button
var leave_button: Button
var end_panel: VBoxContainer
var discovery_button: Button

var winner: String = "none"

func _ready() -> void:
	_build_ui()
	await get_tree().create_timer(0.45).timeout
	_show_post_auction_context()

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

	title_label = Label.new()
	title_label.text = "SESUDAH LELANG"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 30)
	root.add_child(title_label)

	var result: Dictionary = AuctionState.lot_results.get("lot03", {})
	winner = str(result.get("winner", "none"))

	ownership_label = Label.new()
	if winner == "mc":
		ownership_label.text = "Kamera ada di tanganmu."
	elif winner == "jaka":
		ownership_label.text = "Kamera ada di tangan Jaka."
	else:
		ownership_label.text = "Kamera tidak berpindah ke tanganmu."
	ownership_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ownership_label.add_theme_font_size_override("font_size", 20)
	root.add_child(ownership_label)

	main_label = Label.new()
	main_label.text = ""
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_label.custom_minimum_size = Vector2(0, 180)
	main_label.add_theme_font_size_override("font_size", 27)
	root.add_child(main_label)

	detail_label = Label.new()
	detail_label.text = ""
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.custom_minimum_size = Vector2(0, 145)
	detail_label.add_theme_font_size_override("font_size", 19)
	root.add_child(detail_label)

	var npc_row := HBoxContainer.new()
	npc_row.alignment = BoxContainer.ALIGNMENT_CENTER
	npc_row.add_theme_constant_override("separation", 16)
	root.add_child(npc_row)

	ratna_label = _npc_label("Bu Ratna", "NEUTRAL")
	npc_row.add_child(ratna_label)
	jaka_label = _npc_label("Jaka", "NEUTRAL")
	npc_row.add_child(jaka_label)
	slamet_label = _npc_label("Pak Slamet", "NEUTRAL")
	npc_row.add_child(slamet_label)

	choice_panel = HBoxContainer.new()
	choice_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	choice_panel.add_theme_constant_override("separation", 12)
	choice_panel.visible = false
	root.add_child(choice_panel)

	followup_button = Button.new()
	followup_button.custom_minimum_size = Vector2(260, 70)
	followup_button.pressed.connect(_on_followup)
	choice_panel.add_child(followup_button)

	leave_button = Button.new()
	leave_button.custom_minimum_size = Vector2(210, 70)
	leave_button.pressed.connect(_on_leave)
	choice_panel.add_child(leave_button)

	end_panel = VBoxContainer.new()
	end_panel.visible = false
	end_panel.add_theme_constant_override("separation", 14)
	root.add_child(end_panel)

	var end_title := Label.new()
	end_title.text = "SESUDAH LELANG" if AuctionState.chapter_mode else "P0.1 — AUCTION FEEL SELESAI"
	end_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_title.add_theme_font_size_override("font_size", 28)
	end_panel.add_child(end_title)

	var end_copy := Label.new()
	end_copy.text = "Tidak semua barang langsung membuka jawabannya. Kadang kamu harus memilih apakah informasi itu layak dikejar."
	end_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_copy.add_theme_font_size_override("font_size", 18)
	end_panel.add_child(end_copy)

	discovery_button = Button.new()
	discovery_button.text = "PULANG" if AuctionState.chapter_mode else "LANJUT KE TEMUAN"
	discovery_button.custom_minimum_size = Vector2(270, 68)
	discovery_button.visible = true if AuctionState.chapter_mode else _owns_lot02()
	discovery_button.pressed.connect(_continue_after_auction)
	end_panel.add_child(discovery_button)

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

func _show_post_auction_context() -> void:
	if winner == "mc":
		main_label.text = "Peserta mulai berdiri dan membereskan barang."
		detail_label.text = "Pak Slamet melihatmu masih memandangi lensa. \"Kalau benar-benar penasaran, Harun belum pulang. Dia biasa pegang kamera.\""
		slamet_label.text = "Pak Slamet\n[INTERESTED]"
		followup_button.text = "BICARA DENGAN PAK HARUN"
		leave_button.text = "NANTI SAJA"
		choice_panel.visible = true
		return

	if winner == "jaka":
		main_label.text = "Jaka memasukkan kamera ke tasnya, lalu berhenti."
		detail_label.text = "Setelah sindiran Bu Ratna, ia melirik ke meja samping. Pak Harun, teknisi kamera yang tadi menonton dari belakang, masih membereskan alat."
		jaka_label.text = "Jaka\n[SUSPICIOUS]"
		followup_button.text = "TETAP DI SINI"
		leave_button.text = "TINGGALKAN BALAI"
		choice_panel.visible = true
		return

	main_label.text = "Lelang selesai."
	detail_label.text = "Tidak ada alasan untuk melakukan pemeriksaan lanjutan pada kamera."
	await get_tree().create_timer(2.0).timeout
	end_panel.visible = true

func _on_followup() -> void:
	choice_panel.visible = false
	if winner == "jaka":
		main_label.text = "Jaka: \"Harun, sekalian lihat ini. Biar nggak ada yang ngoceh.\""
		detail_label.text = "Bu Ratna belum pergi. Pak Slamet tetap duduk. Kamu memilih tetap di dekat meja."
		jaka_label.text = "Jaka\n[CONFIDENT]"
		await get_tree().create_timer(2.8).timeout
	else:
		main_label.text = "Kamu membawa kamera ke meja samping."
		detail_label.text = "Pak Harun menerima kamera tanpa menjanjikan apa pun. Bu Ratna dan Jaka masih cukup dekat untuk melihat."
		await get_tree().create_timer(2.8).timeout

	await _run_reveal()

func _on_leave() -> void:
	choice_panel.visible = false
	if winner == "mc":
		main_label.text = "Kamu menyimpan kamera."
		detail_label.text = "Nilainya belum diketahui. Kamu memilih tidak mengejar jawabannya sekarang."
	else:
		main_label.text = "Kamu meninggalkan balai."
		detail_label.text = "Apa pun yang kemudian ditemukan Jaka tentang kamera itu, kamu tidak mengetahuinya."
	await get_tree().create_timer(2.2).timeout
	end_panel.visible = true

func _run_reveal() -> void:
	AuctionState.camera_appraisal_seen = true
	title_label.text = "PEMERIKSAAN — PAK HARUN"
	ownership_label.visible = false

	main_label.text = "Pak Harun memeriksa body."
	detail_label.text = "Cepat. Seperti tidak ada yang istimewa."
	await get_tree().create_timer(2.4).timeout

	main_label.text = "Body: Rp90.000–Rp150.000."
	detail_label.text = "Bu Ratna menggeleng pelan. Jaka tidak mengatakan apa-apa."
	ratna_label.text = "Bu Ratna\n[SUSPICIOUS]"
	await get_tree().create_timer(2.7).timeout

	main_label.text = "Pak Harun memutar lensa."
	detail_label.text = ""
	await get_tree().create_timer(2.2).timeout

	main_label.text = "Ia berhenti."
	detail_label.text = ""
	await get_tree().create_timer(1.8).timeout

	main_label.text = "Lensa diangkat ke lampu."
	detail_label.text = "Pak Harun tidak mengatakan apa-apa."
	await get_tree().create_timer(3.0).timeout

	main_label.text = "Kaca pembesar diletakkan."
	detail_label.text = "Ia mengambil lampu lain."
	await get_tree().create_timer(2.7).timeout

	main_label.text = "Ia melihat lagi."
	detail_label.text = ""
	jaka_label.text = "Jaka\n[SUSPICIOUS]"
	await get_tree().create_timer(2.5).timeout

	main_label.text = "Produksi terbatas."
	detail_label.text = "Cincin aperture desain lama. Nomor seri di luar range produksi umum."
	await get_tree().create_timer(3.8).timeout

	main_label.text = "..."
	detail_label.text = ""
	await get_tree().create_timer(1.7).timeout

	main_label.text = "Perkiraan nilai kolektor"
	detail_label.text = "Rp2.800.000 – Rp3.600.000"
	await get_tree().create_timer(4.2).timeout

	main_label.text = ""
	detail_label.text = "Meja itu mendadak sunyi."
	ratna_label.text = "Bu Ratna\n[SURPRISED]"
	jaka_label.text = "Jaka\n[NEUTRAL]"
	slamet_label.text = "Pak Slamet\n[INTERESTED]"
	await get_tree().create_timer(2.0).timeout

	main_label.text = "Bu Ratna: \"Lho?\""
	detail_label.text = ""
	await get_tree().create_timer(2.0).timeout

	main_label.text = "Pak Slamet menutup kacamatanya."
	detail_label.text = "Ia meletakkannya di meja."
	await get_tree().create_timer(2.1).timeout

	main_label.text = ""
	detail_label.text = ""
	end_panel.visible = true

func _owns_lot02() -> bool:
	var result: Dictionary = AuctionState.lot_results.get("lot02", {})
	return str(result.get("winner", "")) == "mc"

func _continue_after_auction() -> void:
	if AuctionState.chapter_mode:
		get_tree().change_scene_to_file("res://scenes/chapter/chapter1_home.tscn")
		return
	get_tree().change_scene_to_file("res://scenes/discovery/discovery_loop.tscn")

func _restart() -> void:
	if AuctionState.chapter_mode:
		get_tree().change_scene_to_file("res://scenes/chapter/chapter1_intro.tscn")
		return
	AuctionState.reset_prototype()
	get_tree().change_scene_to_file("res://scenes/auction/auction_room.tscn")
