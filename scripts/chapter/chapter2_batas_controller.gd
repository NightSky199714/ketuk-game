extends Control

const MAP_DATA_PATH := "res://data/chapter/chapter2_batas_map.json"

var map_data: Dictionary = {}
var current_location_id: String = "rumah"
var chapter_done: bool = false

var title_label: Label
var clock_label: Label
var money_label: Label
var clue_label: Label
var map_row: HBoxContainer
var location_label: Label
var location_description: Label
var response_label: Label
var action_row: VBoxContainer
var continue_button: Button
var location_buttons: Dictionary = {}

func _ready() -> void:
	AuctionState.start_chapter2()
	_load_map()
	_build_ui()
	_show_location("rumah", false)
	_show_opening()

func _load_map() -> void:
	if not FileAccess.file_exists(MAP_DATA_PATH):
		push_error("Chapter 2 map data not found: %s" % MAP_DATA_PATH)
		return

	var file := FileAccess.open(MAP_DATA_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		map_data = parsed
	else:
		push_error("Chapter 2 map data invalid.")

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#1d1815")
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
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	title_label = Label.new()
	title_label.text = "BAB 2 — BATAS"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 29)
	root.add_child(title_label)

	clock_label = Label.new()
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_label.add_theme_font_size_override("font_size", 18)
	root.add_child(clock_label)

	money_label = Label.new()
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	money_label.add_theme_font_size_override("font_size", 17)
	root.add_child(money_label)

	clue_label = Label.new()
	clue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	clue_label.custom_minimum_size = Vector2(0, 90)
	clue_label.add_theme_font_size_override("font_size", 16)
	root.add_child(clue_label)

	var map_title := Label.new()
	map_title.text = "PETA"
	map_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_title.add_theme_font_size_override("font_size", 17)
	root.add_child(map_title)

	map_row = HBoxContainer.new()
	map_row.alignment = BoxContainer.ALIGNMENT_CENTER
	map_row.add_theme_constant_override("separation", 5)
	root.add_child(map_row)

	var order := [
		"rumah",
		"toko_kamera",
		"warung_ratna",
		"pak_arman",
		"kedai_foto",
		"terminal_kota",
		"alamat_sentana"
	]

	for location_id in order:
		var button := Button.new()
		button.custom_minimum_size = Vector2(112, 58)
		var captured_id: String = location_id
		button.pressed.connect(func(): _travel_to(captured_id))
		map_row.add_child(button)
		location_buttons[location_id] = button

	location_label = Label.new()
	location_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_label.add_theme_font_size_override("font_size", 23)
	root.add_child(location_label)

	location_description = Label.new()
	location_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	location_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	location_description.custom_minimum_size = Vector2(0, 110)
	location_description.add_theme_font_size_override("font_size", 17)
	root.add_child(location_description)

	response_label = Label.new()
	response_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	response_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response_label.custom_minimum_size = Vector2(0, 190)
	response_label.add_theme_font_size_override("font_size", 18)
	root.add_child(response_label)

	action_row = VBoxContainer.new()
	action_row.add_theme_constant_override("separation", 7)
	root.add_child(action_row)

	continue_button = Button.new()
	continue_button.visible = false
	continue_button.custom_minimum_size = Vector2(280, 66)
	continue_button.pressed.connect(_continue_after_chapter)
	root.add_child(continue_button)

	_refresh_status()
	_refresh_map()

func _show_opening() -> void:
	var owns_camera := _owns_camera()
	if owns_camera:
		response_label.text = "Minggu sore. Kamera masih ada di tanganmu. Tunggakan kios harus lunas sebelum jam delapan malam."
		if AuctionState.camera_appraisal_seen:
			clue_label.text = "CATATAN — Pak Harun pernah bilang body biasa, tetapi lensanya punya pasar kolektor."
		else:
			clue_label.text = "CATATAN — Kamera belum memberi uang hanya karena kelihatannya menarik."
	else:
		response_label.text = "Minggu sore. Kamera bukan milikmu. Tunggakan kios tetap harus lunas sebelum jam delapan malam."
		clue_label.text = "CATATAN — Kamu butuh cara lain untuk menghadapi tunggakan."

	_refresh_actions()

func _travel_to(location_id: String) -> void:
	if chapter_done:
		return
	if not AuctionState.chapter2_known_places.has(location_id):
		return
	if location_id == current_location_id:
		_show_location(location_id, false)
		return

	var travel_minutes := _travel_minutes(location_id)
	AuctionState.advance_chapter2_time(travel_minutes)
	current_location_id = location_id
	AuctionState.chapter2_visited[location_id] = true
	_show_location(location_id, true)

	if _check_hard_deadline():
		return

func _show_location(location_id: String, moved: bool) -> void:
	var locations: Dictionary = map_data.get("locations", {})
	var location: Dictionary = locations.get(location_id, {})
	if location.is_empty():
		return

	current_location_id = location_id
	location_label.text = str(location.get("label", location_id)).to_upper()
	location_description.text = str(location.get("description", ""))

	if moved:
		response_label.text = "Kamu tiba di %s." % str(location.get("label", location_id))
	else:
		response_label.text = ""

	_refresh_status()
	_refresh_map()
	_refresh_actions()

func _refresh_actions() -> void:
	_clear_actions()
	if chapter_done:
		return

	match current_location_id:
		"rumah":
			_build_home_actions()
		"toko_kamera":
			_build_camera_shop_actions()
		"warung_ratna":
			_add_action("BICARA DENGAN BU RATNA", _talk_ratna)
		"pak_arman":
			_build_arman_actions()
		"kedai_foto":
			_build_adi_actions()
		"terminal_kota":
			_build_terminal_actions()
		"alamat_sentana":
			_build_sentana_actions()

func _build_home_actions() -> void:
	if AuctionState.chapter2_extension_granted and AuctionState.chapter2_day_name() == "Minggu":
		_add_action("ISTIRAHAT SAMPAI SENIN PAGI", _wait_until_monday)
	else:
		_add_action("TUNGGU SATU JAM", _wait_one_hour)

func _build_camera_shop_actions() -> void:
	if not _owns_camera():
		response_label.text = "Rak kamera lama ada di belakang kaca. Kamu tidak membawa kamera yang bisa ditawarkan."
		return

	if AuctionState.camera_sale_status.is_empty():
		_add_action("BICARA DENGAN PAK HARUN", _talk_harun)
		if AuctionState.chapter2_pending_offer > 0:
			_add_action(
				"TERIMA %s" % _rupiah(AuctionState.chapter2_pending_offer),
				_accept_harun_offer
			)

func _build_arman_actions() -> void:
	_add_action("BICARA DENGAN PAK ARMAN", _talk_arman)

	var remaining := maxi(AuctionState.kiosk_arrears - AuctionState.kiosk_paid, 0)
	if remaining > 0 and AuctionState.money >= remaining:
		_add_action("BAYAR TUNGGAKAN %s" % _rupiah(remaining), _pay_arman)

func _build_adi_actions() -> void:
	if not AuctionState.chapter2_leads.has("adi"):
		response_label.text = "Kedai kecil itu tidak berarti banyak bagimu. Belum ada alasan khusus untuk mencari seseorang di sini."
		return

	if AuctionState.chapter2_day_name() == "Minggu":
		_add_action("CEK KEDAI FOTO", _check_adi_sunday)
		return

	if _owns_camera() and AuctionState.camera_sale_status.is_empty():
		_add_action("TEMUI ADI", _meet_adi)

func _build_terminal_actions() -> void:
	if not AuctionState.chapter2_leads.has("sentana"):
		response_label.text = "Terminal ramai. Tanpa nama atau alasan, bertanya di sini hanya membuang waktu."
		return

	if not AuctionState.chapter2_leads.has("sentana_address"):
		_add_action("TANYA-TANYA", _ask_terminal)
	else:
		response_label.text = "Kamu sudah punya satu alamat yang mungkin terkait dengan nama Sentana."

func _build_sentana_actions() -> void:
	if not AuctionState.chapter2_leads.has("sentana_address"):
		response_label.text = "Alamat ini belum berarti apa-apa bagimu."
		return

	_add_action("CARI ORANG DI ALAMAT INI", _search_sentana_address)

func _talk_harun() -> void:
	AuctionState.advance_chapter2_time(20)
	if _check_hard_deadline():
		return

	var offer := 1650000
	if AuctionState.chapter2_time_minutes >= 18 * 60:
		offer = 1500000

	AuctionState.chapter2_pending_offer = offer
	AuctionState.chapter2_leads["adi"] = true
	AuctionState.chapter2_known_places["kedai_foto"] = true

	response_label.text = "Pak Harun melihat kamera dan lensanya sekali lagi.\n\n\"Kalau saya ambil sekarang, %s. Saya tetap harus punya ruang buat jual lagi.\"\n\nSaat kamu tidak langsung menjawab, ia menambahkan, \"Kalau yang dicari cuma lensanya, Adi kadang beli barang begini. Dia biasa muncul di kedai foto lama.\"" % _rupiah(offer)

	clue_label.text = "CATATAN — Harun memberi angka tunai sekarang. Nama Adi muncul sebagai orang yang kadang membeli lensa saja."
	_refresh_status()
	_refresh_map()
	_refresh_actions()

func _accept_harun_offer() -> void:
	if AuctionState.chapter2_pending_offer <= 0:
		return

	var offer := AuctionState.chapter2_pending_offer
	AuctionState.money += offer
	AuctionState.camera_sale_status = "sold_full_1650" if offer >= 1650000 else "sold_full_1500_late"
	AuctionState.chapter2_pending_offer = 0

	response_label.text = "Kamera berpindah tangan. %s masuk ke dompetmu. Pak Harun tidak ikut mengurus tunggakan kios; itu tetap urusanmu." % _rupiah(offer)
	clue_label.text = "CATATAN — Kamera sudah terjual. Deadline kios tetap berjalan."
	_refresh_status()
	_refresh_actions()

func _talk_ratna() -> void:
	AuctionState.advance_chapter2_time(15)
	if _check_hard_deadline():
		return

	if _owns_camera():
		AuctionState.chapter2_leads["sentana"] = true
		AuctionState.chapter2_known_places["terminal_kota"] = true
		response_label.text = "Bu Ratna melihat tas kameramu.\n\n\"Kalau kamu memang cari orang yang berani bayar barang aneh, aku pernah dengar nama Sentana. Bukan orang pasar sini. Sopir-sopir kota yang pernah ngomong.\"\n\nIa tidak punya alamat."
		clue_label.text = "CATATAN — Nama Sentana pernah terdengar dari orang-orang yang datang dari kota."
	else:
		response_label.text = "Bu Ratna tidak punya solusi cepat untuk tunggakanmu. Ia cuma mengingatkan bahwa orang pasar sering tahu orang lain, bukan selalu tahu harga barang."
		clue_label.text = "CATATAN — Jaringan bisa berguna, tapi tidak otomatis menghasilkan uang."

	_refresh_status()
	_refresh_map()
	_refresh_actions()

func _talk_arman() -> void:
	AuctionState.advance_chapter2_time(10)
	if _check_hard_deadline():
		return

	if AuctionState.chapter2_leads.has("adi_waiting") and not AuctionState.chapter2_extension_granted:
		AuctionState.chapter2_extension_granted = true
		response_label.text = "Kamu menjelaskan bahwa ada pembeli lensa, tetapi baru Senin pagi.\n\nPak Arman diam sebentar. \"Senin jam sepuluh. Lewat itu, saya anggap kamu tidak sanggup.\"\n\nTidak ada diskon. Hanya waktu."
		clue_label.text = "CATATAN — Batas baru: Senin 10:00."
	else:
		response_label.text = "\"Saya cuma perlu kepastian,\" kata Pak Arman. \"Kalau ada uangnya, bayar. Kalau belum, batasnya tetap.\""

	_refresh_status()
	_refresh_actions()

func _pay_arman() -> void:
	var remaining := maxi(AuctionState.kiosk_arrears - AuctionState.kiosk_paid, 0)
	if remaining <= 0 or AuctionState.money < remaining:
		return

	AuctionState.pay_kiosk(remaining)

	if AuctionState.camera_sale_status == "lens_only_2100_body_returned":
		AuctionState.finish_chapter2("B2_ADI")
	elif AuctionState.camera_sale_status == "sold_full_1500_late":
		AuctionState.finish_chapter2("B3A_LATE_RETURN")
	elif AuctionState.camera_sale_status == "sold_full_1650":
		AuctionState.finish_chapter2("B1_SAFE_SALE")
	else:
		AuctionState.finish_chapter2("PAID_OTHER")

	response_label.text = "Pak Arman menghitung uangnya sekali. Tunggakan lunas. Kios tetap bisa dibuka."
	clue_label.text = "CATATAN — Utang kios selesai. Harga kamera dan keputusan waktumu tetap punya konsekuensi sendiri."
	_finish_chapter2()

func _check_adi_sunday() -> void:
	var target := 18 * 60
	if AuctionState.chapter2_time_minutes < target:
		AuctionState.chapter2_time_minutes = target
	else:
		AuctionState.advance_chapter2_time(20)

	if _check_hard_deadline():
		return

	AuctionState.chapter2_leads["adi_waiting"] = true
	response_label.text = "Kedai hampir tutup. Adi tidak ada di sana.\n\nPemilik kedai menunjukkan pesan yang baru masuk: \"Lensa saja. Rp2.100.000. Bisa ketemu Senin pagi. Body bawa pulang.\""
	clue_label.text = "CATATAN — Adi: Rp2.100.000 untuk lensa saja, tetapi baru Senin pagi."
	_refresh_status()
	_refresh_actions()

func _wait_until_monday() -> void:
	AuctionState.chapter2_time_minutes = 24 * 60 + 8 * 60 + 40
	response_label.text = "Malam lewat. Kamu bangun sebelum jam sembilan."
	_refresh_status()
	_refresh_actions()

func _meet_adi() -> void:
	if not AuctionState.chapter2_extension_granted:
		response_label.text = "Adi bisa membeli lensanya, tetapi urusan kiosmu belum punya waktu tambahan."
		return

	AuctionState.advance_chapter2_time(20)
	if _check_hard_deadline():
		return

	AuctionState.money += 2100000
	AuctionState.camera_sale_status = "lens_only_2100_body_returned"
	response_label.text = "Adi memeriksa lensa lebih lama daripada body.\n\nRp2.100.000 untuk lensa. Body dikembalikan kepadamu."
	clue_label.text = "CATATAN — Lensa sudah terjual. Batas Pak Arman: Senin 10:00."
	_refresh_status()
	_refresh_actions()

func _ask_terminal() -> void:
	if AuctionState.chapter2_time_minutes < 17 * 60 + 5:
		AuctionState.chapter2_time_minutes = 17 * 60 + 5
	AuctionState.advance_chapter2_time(55)

	if _check_hard_deadline():
		return

	AuctionState.chapter2_leads["sentana_address"] = true
	AuctionState.chapter2_known_places["alamat_sentana"] = true
	response_label.text = "Beberapa orang menggeleng. Seorang sopir akhirnya mengenali namanya.\n\n\"Sentana? Pernah antar orang ke alamat di kota. Belum tentu orang yang sama.\"\n\nIa memberimu patokan jalan, bukan kepastian."
	clue_label.text = "CATATAN — Ada satu alamat yang mungkin terkait Sentana. Belum terverifikasi."
	_refresh_status()
	_refresh_map()
	_refresh_actions()

func _search_sentana_address() -> void:
	AuctionState.advance_chapter2_time(150)

	if AuctionState.chapter2_time_minutes <= 20 * 60:
		AuctionState.chapter2_time_minutes = 20 * 60 + 30

	AuctionState.kiosk_saved = false
	AuctionState.finish_chapter2("B3B_CHASE_TOO_LONG")
	chapter_done = true

	title_label.text = "MINGGU — %s" % AuctionState.chapter2_clock()
	response_label.text = "Alamatnya nyata. Sentana tidak ada.\n\nSaat kamu kembali, waktu sudah lewat. Pak Arman telah menutup kios dan menyerahkan papan namanya dengan hati-hati."
	clue_label.text = "CATATAN — Kamu menemukan alamat, bukan pembeli."
	continue_button.text = "ESOK PAGI"
	continue_button.visible = true
	_clear_actions()
	_refresh_status()

func _wait_one_hour() -> void:
	AuctionState.advance_chapter2_time(60)
	response_label.text = "Satu jam lewat."
	_refresh_status()

	if _check_hard_deadline():
		return

	_refresh_actions()

func _check_hard_deadline() -> bool:
	if AuctionState.kiosk_saved:
		return false

	if not AuctionState.chapter2_past_deadline():
		return false

	AuctionState.kiosk_saved = false
	if not AuctionState.chapter2_complete:
		AuctionState.finish_chapter2("A_KIOS_LOST")

	chapter_done = true
	title_label.text = "%s — %s" % [
		AuctionState.chapter2_day_name().to_upper(),
		AuctionState.chapter2_clock()
	]
	response_label.text = "Batas lewat tanpa pembayaran penuh. Pak Arman menutup kios dan menyerahkan papan namanya kembali."
	clue_label.text = "CATATAN — Waktu habis. Cerita tidak berhenti."
	continue_button.text = "LANJUT BAB 3"
	continue_button.visible = true
	_clear_actions()
	_refresh_status()
	return true

func _finish_chapter2() -> void:
	chapter_done = true
	title_label.text = "BAB 2 — BATAS"
	response_label.text += "\n\nKios selamat. Bukan karena game memilihkan jalur, tetapi karena kamu menemukan cara mengubah aset menjadi uang sebelum batas."
	continue_button.text = "LANJUT BAB 3"
	continue_button.visible = true
	_clear_actions()
	_refresh_status()

func _continue_after_chapter() -> void:
	if AuctionState.chapter2_route == "B3B_CHASE_TOO_LONG" and AuctionState.chapter2_day_name() == "Minggu":
		AuctionState.chapter2_time_minutes = 24 * 60 + 9 * 60 + 10
		title_label.text = "SENIN — 09:10"
		response_label.text = "Pesan masuk dari nomor yang kemarin tidak menjawab.\n\nSentana ternyata nyata. Ia menawarkan Rp3.800.000 setelah melihat foto lensa. Kios tetap sudah hilang."
		clue_label.text = "CATATAN — Harga tertinggi datang setelah waktu yang dibutuhkan habis."
		continue_button.text = "LANJUT BAB 3"
		_refresh_status()
		return

	get_tree().change_scene_to_file("res://scenes/chapter/chapter3_orang_yang_tepat.tscn")

func _refresh_status() -> void:
	clock_label.text = "Waktu: %s %s  |  Batas: %s" % [
		AuctionState.chapter2_day_name(),
		AuctionState.chapter2_clock(),
		AuctionState.chapter2_deadline_label()
	]

	money_label.text = "Uang: %s  |  Tunggakan: %s" % [
		_rupiah(AuctionState.money),
		_rupiah(maxi(AuctionState.kiosk_arrears - AuctionState.kiosk_paid, 0))
	]

func _refresh_map() -> void:
	var locations: Dictionary = map_data.get("locations", {})
	for location_id in location_buttons.keys():
		var button: Button = location_buttons[location_id]
		var known := AuctionState.chapter2_known_places.has(location_id)
		button.visible = known
		if not known:
			continue

		var location: Dictionary = locations.get(location_id, {})
		var label := str(location.get("label", location_id)).to_upper()
		if location_id == current_location_id:
			label = "• " + label
		button.text = label

func _clear_actions() -> void:
	for child in action_row.get_children():
		child.queue_free()

func _add_action(label: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(0, 60)
	button.pressed.connect(callback)
	action_row.add_child(button)

func _travel_minutes(location_id: String) -> int:
	match location_id:
		"terminal_kota":
			return 30
		"alamat_sentana":
			return 20
		_:
			return 20

func _owns_camera() -> bool:
	var lot03: Dictionary = AuctionState.lot_results.get("lot03", {})
	if str(lot03.get("winner", "")) != "mc":
		return false
	return AuctionState.camera_sale_status.is_empty()

func _rupiah(value: int) -> String:
	var raw := str(value)
	var formatted := ""
	while raw.length() > 3:
		formatted = "." + raw.substr(raw.length() - 3, 3) + formatted
		raw = raw.substr(0, raw.length() - 3)
	return "Rp" + raw + formatted
