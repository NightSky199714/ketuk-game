extends Control

const MAP_DATA_PATH := "res://data/chapter/chapter2_batas_map.json"

var map_data: Dictionary = {}
var current_location_id: String = "rumah"

var title_label: Label
var clock_label: Label
var money_label: Label
var clue_label: Label
var inventory_grid: GridContainer
var inventory_detail: Label
var map_row: GridContainer
var location_label: Label
var location_description: Label
var response_label: Label
var action_row: VBoxContainer
var location_buttons: Dictionary = {}

func _ready() -> void:
	AuctionState.start_chapter2()
	_load_map()
	_build_ui()
	_show_location("rumah", false)
	_show_opening()

func _load_map() -> void:
	if not FileAccess.file_exists(MAP_DATA_PATH):
		push_error("World map data not found: %s" % MAP_DATA_PATH)
		return

	var file := FileAccess.open(MAP_DATA_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		map_data = parsed
	else:
		push_error("World map data invalid.")

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#1d1815")
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
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 27)
	root.add_child(title_label)

	clock_label = Label.new()
	clock_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_label.add_theme_font_size_override("font_size", 17)
	root.add_child(clock_label)

	money_label = Label.new()
	money_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	money_label.add_theme_font_size_override("font_size", 16)
	root.add_child(money_label)

	clue_label = Label.new()
	clue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	clue_label.custom_minimum_size = Vector2(0, 70)
	clue_label.add_theme_font_size_override("font_size", 15)
	root.add_child(clue_label)

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
	inventory_detail.custom_minimum_size = Vector2(0, 105)
	inventory_detail.add_theme_font_size_override("font_size", 15)
	root.add_child(inventory_detail)

	var map_title := Label.new()
	map_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_title.text = "PETA"
	map_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	map_title.add_theme_font_size_override("font_size", 16)
	root.add_child(map_title)

	map_row = GridContainer.new()
	map_row.columns = 2
	map_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_row.add_theme_constant_override("h_separation", 8)
	map_row.add_theme_constant_override("v_separation", 8)
	root.add_child(map_row)

	var order := [
		"rumah",
		"toko_kamera",
		"warung_ratna",
		"pak_arman",
		"bengkel_umum",
		"pasar_tua",
		"kedai_foto",
		"terminal_kota",
		"alamat_sentana"
	]

	for location_id in order:
		var button := Button.new()
		button.custom_minimum_size = Vector2(0, 54)
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
	location_description.custom_minimum_size = Vector2(0, 85)
	location_description.add_theme_font_size_override("font_size", 16)
	root.add_child(location_description)

	response_label = Label.new()
	response_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	response_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	response_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response_label.custom_minimum_size = Vector2(0, 135)
	response_label.add_theme_font_size_override("font_size", 17)
	root.add_child(response_label)

	action_row = VBoxContainer.new()
	action_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_theme_constant_override("separation", 7)
	root.add_child(action_row)

	_refresh_status()
	_refresh_inventory()
	_refresh_map()

func _show_opening() -> void:
	title_label.text = "MINGGU SORE"
	response_label.text = "Tunggakan kios masih berjalan. Barang hasil lelang ada di inventory; selebihnya tergantung apa yang kamu coba."
	clue_label.text = "Tidak ada tujuan aktif."
	_refresh_actions()

func _travel_to(location_id: String) -> void:
	if not AuctionState.chapter2_known_places.has(location_id):
		return
	if location_id == current_location_id:
		_show_location(location_id, false)
		return

	AuctionState.advance_chapter2_time(_travel_minutes(location_id))
	current_location_id = location_id
	AuctionState.chapter2_visited[location_id] = true
	_show_location(location_id, true)
	_check_deadline_event()

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
	_refresh_inventory()
	_refresh_map()
	_refresh_actions()

func _refresh_actions() -> void:
	_clear_actions()

	match current_location_id:
		"rumah":
			_build_home_actions()
		"toko_kamera":
			_add_action("BICARA DENGAN PAK HARUN", _talk_harun)
			_add_show_item_action()
		"warung_ratna":
			_add_action("BICARA DENGAN BU RATNA", _talk_ratna)
			_add_show_item_action()
		"pak_arman":
			_add_action("BICARA DENGAN PAK ARMAN", _talk_arman)
			var remaining := maxi(AuctionState.kiosk_arrears - AuctionState.kiosk_paid, 0)
			if remaining > 0 and AuctionState.money >= remaining:
				_add_action("BAYAR %s" % _rupiah(remaining), _pay_arman)
		"bengkel_umum":
			_add_action("BICARA DENGAN PENGRAJIN", _talk_craftsman)
			_add_show_item_action()
		"pasar_tua":
			_add_action("MASUK PASAR", _enter_old_market)
		"kedai_foto":
			_build_adi_actions()
		"terminal_kota":
			_build_terminal_actions()
		"alamat_sentana":
			_build_sentana_actions()

func _build_home_actions() -> void:
	if AuctionState.chapter2_extension_granted and AuctionState.chapter2_day_name() == "Minggu":
		_add_action("ISTIRAHAT", _wait_until_monday)
	else:
		_add_action("TUNGGU SATU JAM", _wait_one_hour)

func _add_show_item_action() -> void:
	if AuctionState.selected_inventory_item.is_empty():
		return
	if not AuctionState.has_inventory_item(AuctionState.selected_inventory_item):
		return
	_add_action("TUNJUKKAN BARANG", _show_selected_item_here)

func _show_selected_item_here() -> void:
	var item_id := AuctionState.selected_inventory_item
	if item_id.is_empty():
		return

	match current_location_id:
		"toko_kamera":
			_show_item_to_harun(item_id)
		"warung_ratna":
			_show_item_to_ratna(item_id)
		"bengkel_umum":
			_show_item_to_craftsman(item_id)
		_:
			response_label.text = "Tidak ada reaksi khusus terhadap barang itu di sini."

	_refresh_inventory()
	_refresh_actions()

func _show_item_to_harun(item_id: String) -> void:
	AuctionState.advance_chapter2_time(10)
	if item_id == "camera" and AuctionState.has_inventory_item("camera"):
		var offer := 1650000
		if AuctionState.chapter2_time_minutes >= 18 * 60:
			offer = 1500000
		AuctionState.chapter2_pending_offer = offer
		AuctionState.chapter2_leads["adi"] = true
		AuctionState.chapter2_known_places["kedai_foto"] = true
		response_label.text = "Pak Harun memeriksa kamera.\n\n\"Kalau saya ambil sekarang, %s.\"\n\nIa menyebut seseorang bernama Adi yang kadang membeli lensa tanpa bodynya." % _rupiah(offer)
		clue_label.text = "Nama Adi terdengar. Pak Harun menyebut kedai foto lama."
		_add_action("TERIMA %s" % _rupiah(offer), _accept_harun_offer)
	elif item_id == "mixed_box":
		response_label.text = "Pak Harun menekan tutup kotak sebentar lalu mengembalikannya. \"Bukan alat saya. Saya nggak mau paksa dan merusak isinya.\""
	else:
		response_label.text = "Pak Harun melihat barang itu, lalu menggeleng. \"Kalau bukan kamera atau optik, saya cuma akan nebak.\""

func _talk_harun() -> void:
	AuctionState.advance_chapter2_time(10)
	response_label.text = "Pak Harun sedang membersihkan lensa di meja. Ia tidak bertanya apa yang kamu bawa."
	if AuctionState.chapter2_time_minutes >= 18 * 60 and AuctionState.chapter2_pending_offer > 1500000:
		AuctionState.chapter2_pending_offer = 1500000
	_refresh_status()

func _accept_harun_offer() -> void:
	if AuctionState.chapter2_pending_offer <= 0:
		return
	if not AuctionState.has_inventory_item("camera"):
		return

	var offer := AuctionState.chapter2_pending_offer
	AuctionState.money += offer
	AuctionState.camera_sale_status = "sold_full_1650" if offer >= 1650000 else "sold_full_1500_late"
	AuctionState.chapter2_pending_offer = 0
	AuctionState.remove_inventory_item("camera")
	response_label.text = "Kamera berpindah tangan. %s masuk ke dompetmu." % _rupiah(offer)
	clue_label.text = "Kamera sudah tidak ada di inventory."
	_refresh_status()
	_refresh_inventory()
	_refresh_actions()

func _talk_ratna() -> void:
	AuctionState.advance_chapter2_time(10)
	response_label.text = "Bu Ratna sedang melayani dua orang. Obrolan di warung berpindah-pindah dari harga beras sampai orang kota."
	_refresh_status()

func _show_item_to_ratna(item_id: String) -> void:
	AuctionState.advance_chapter2_time(10)
	if item_id == "camera":
		AuctionState.chapter2_leads["sentana"] = true
		AuctionState.chapter2_known_places["terminal_kota"] = true
		response_label.text = "Bu Ratna melihat tas kameramu. \"Pernah dengar nama Sentana dari sopir-sopir kota. Katanya suka barang aneh. Nggak tahu orangnya yang mana.\""
		clue_label.text = "Nama Sentana pernah disebut orang yang datang dari kota."
	elif item_id == "mixed_box":
		response_label.text = "Bu Ratna mengetuk sisi kotaknya. \"Berat. Tapi kalau macet begini jangan dipaksa pakai pisau dapur.\""
	else:
		response_label.text = "Bu Ratna melihatnya sebentar. \"Aku bisa jual makanan. Kalau barang begini, aku cuma bisa ikut penasaran.\""

func _talk_craftsman() -> void:
	AuctionState.advance_chapter2_time(10)
	response_label.text = "Pengrajin itu sedang memperbaiki engsel lemari. Meja kerjanya penuh ragum, tang, dan alat kecil."
	_refresh_status()

func _show_item_to_craftsman(item_id: String) -> void:
	AuctionState.advance_chapter2_time(20)
	if item_id == "mixed_box":
		var box := AuctionState.get_inventory_item("mixed_box")
		if str(box.get("state", "")) == "closed":
			response_label.text = "Ia menjepit bagian luar kotak dengan kain, lalu bekerja pada penguncinya beberapa menit.\n\n\"Bukan terkunci. Cuma mekanismenya macet.\"\n\nTutup akhirnya terbuka."
			AuctionState.open_mixed_box()
			AuctionState.selected_inventory_item = ""
			clue_label.text = "Isi kotak sekarang masuk ke inventory."
		else:
			response_label.text = "Kotaknya sudah terbuka."
	elif item_id == "camera":
		response_label.text = "\"Bisa saya buka sekrupnya, tapi itu bukan berarti saya paham kameranya.\""
	else:
		response_label.text = "\"Kalau cuma mau dibuka atau dibetulkan mekaniknya mungkin bisa. Kalau mau tahu nilainya, itu urusan lain.\""

func _talk_arman() -> void:
	AuctionState.advance_chapter2_time(10)
	if AuctionState.chapter2_leads.has("adi_waiting") and not AuctionState.chapter2_extension_granted:
		AuctionState.chapter2_extension_granted = true
		response_label.text = "Kamu menjelaskan bahwa ada pembeli yang baru bisa ditemui Senin.\n\nPak Arman memberi waktu sampai Senin 10:00."
		clue_label.text = "Batas pembayaran berubah: Senin 10:00."
	else:
		response_label.text = "\"Kalau ada uangnya, bayar. Kalau belum, batasnya tetap,\" kata Pak Arman."
	_refresh_status()

func _pay_arman() -> void:
	var remaining := maxi(AuctionState.kiosk_arrears - AuctionState.kiosk_paid, 0)
	if remaining <= 0 or AuctionState.money < remaining:
		return

	AuctionState.pay_kiosk(remaining)
	AuctionState.kiosk_saved = true
	AuctionState.world_flags["kiosk_resolved"] = true
	response_label.text = "Pak Arman menghitung uangnya. Tunggakan lunas."
	clue_label.text = "Kios tetap bisa dipakai."
	_refresh_status()
	_refresh_actions()

func _build_adi_actions() -> void:
	if not AuctionState.chapter2_leads.has("adi"):
		response_label.text = "Kedai foto buka, tetapi tidak ada alasan khusus yang membuatmu mencari seseorang di sini."
		return

	if not AuctionState.has_inventory_item("camera"):
		response_label.text = "Lead tentang pembeli lensa masih ada, tapi kameranya sudah tidak ada di inventory."
		return

	if AuctionState.chapter2_day_name() == "Minggu":
		_add_action("LIHAT- LIHAT", _check_adi_sunday)
	else:
		_add_action("BICARA DENGAN ADI", _meet_adi)

func _check_adi_sunday() -> void:
	if AuctionState.chapter2_time_minutes < 18 * 60:
		AuctionState.chapter2_time_minutes = 18 * 60
	else:
		AuctionState.advance_chapter2_time(15)

	AuctionState.chapter2_leads["adi_waiting"] = true
	response_label.text = "Adi tidak ada. Pemilik kedai menunjukkan pesan singkat: lensa saja, Rp2.100.000, Senin pagi."
	clue_label.text = "Adi baru bisa ditemui Senin pagi."
	_refresh_status()
	_refresh_actions()
	_check_deadline_event()

func _wait_until_monday() -> void:
	AuctionState.chapter2_time_minutes = 24 * 60 + 8 * 60 + 40
	response_label.text = "Pagi datang."
	_refresh_status()
	_refresh_actions()
	_check_deadline_event()

func _meet_adi() -> void:
	if not AuctionState.chapter2_extension_granted:
		response_label.text = "Adi ada di sana, tetapi deadline kiosmu sudah tidak cocok dengan waktunya."
		return
	if not AuctionState.has_inventory_item("camera"):
		return

	AuctionState.advance_chapter2_time(20)
	AuctionState.money += 2100000
	AuctionState.camera_sale_status = "lens_only_2100_body_returned"
	AuctionState.update_inventory_item("camera", {
		"name": "BODY KAMERA",
		"description": "Body kamera tanpa lensa. Lensanya sudah dijual kepada Adi."
	})
	response_label.text = "Adi membeli lensanya seharga Rp2.100.000. Body dikembalikan."
	clue_label.text = "Body kamera tetap di inventory."
	_refresh_status()
	_refresh_inventory()
	_refresh_actions()

func _build_terminal_actions() -> void:
	if not AuctionState.chapter2_leads.has("sentana"):
		response_label.text = "Terminal ramai. Tanpa nama tertentu, tidak banyak yang bisa ditanyakan."
		return
	if not AuctionState.chapter2_leads.has("sentana_address"):
		_add_action("DUDUK DAN MENDENGAR", _ask_terminal)
	else:
		response_label.text = "Satu alamat yang mungkin terkait Sentana sudah kamu catat."

func _ask_terminal() -> void:
	AuctionState.advance_chapter2_time(55)
	AuctionState.chapter2_leads["sentana_address"] = true
	AuctionState.chapter2_known_places["alamat_sentana"] = true
	response_label.text = "Seorang sopir mengenali nama Sentana dan memberi patokan sebuah alamat. Ia sendiri tidak yakin itu orang yang sama."
	clue_label.text = "Ada satu alamat yang belum terverifikasi."
	_refresh_status()
	_refresh_map()
	_refresh_actions()
	_check_deadline_event()

func _build_sentana_actions() -> void:
	if not AuctionState.chapter2_leads.has("sentana_address"):
		return
	_add_action("DATANGI RUMAH", _search_sentana_address)

func _search_sentana_address() -> void:
	AuctionState.advance_chapter2_time(150)
	AuctionState.chapter2_leads["sentana_chased"] = true
	response_label.text = "Alamatnya nyata. Sentana tidak ada di sana."
	clue_label.text = "Kamu menemukan alamat, bukan pembeli."
	_refresh_status()
	_check_deadline_event()

func _enter_old_market() -> void:
	get_tree().change_scene_to_file("res://scenes/chapter/chapter3_orang_yang_tepat.tscn")

func _wait_one_hour() -> void:
	AuctionState.advance_chapter2_time(60)
	response_label.text = "Satu jam lewat."
	_refresh_status()
	_refresh_actions()
	_check_deadline_event()

func _check_deadline_event() -> void:
	if AuctionState.world_flags.has("kiosk_resolved"):
		return
	if not AuctionState.chapter2_past_deadline():
		return

	AuctionState.kiosk_saved = false
	AuctionState.world_flags["kiosk_resolved"] = true
	AuctionState.world_flags["kiosk_lost"] = true
	response_label.text += "\n\nSaat batas lewat tanpa pembayaran penuh, Pak Arman menutup kios dan mengembalikan papan namanya."
	clue_label.text = "Kios sudah ditutup. Dunia tetap berjalan."
	_refresh_actions()

func _select_inventory_item(item_id: String) -> void:
	AuctionState.selected_inventory_item = item_id
	_refresh_inventory()
	_refresh_actions()

func _refresh_inventory() -> void:
	for child in inventory_grid.get_children():
		child.queue_free()

	for item_id in AuctionState.inventory.keys():
		var item: Dictionary = AuctionState.get_inventory_item(str(item_id))
		var button := Button.new()
		button.text = str(item.get("name", str(item_id).to_upper()))
		button.custom_minimum_size = Vector2(0, 48)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var captured_id := str(item_id)
		button.pressed.connect(func(): _select_inventory_item(captured_id))
		inventory_grid.add_child(button)

	if AuctionState.inventory.is_empty():
		inventory_detail.text = "Inventory kosong."
		return

	var selected := AuctionState.selected_inventory_item
	if selected.is_empty() or not AuctionState.has_inventory_item(selected):
		inventory_detail.text = "Pilih barang. Barang yang dipilih bisa dicoba di tempat berbeda."
		return

	var item := AuctionState.get_inventory_item(selected)
	inventory_detail.text = "%s\n%s" % [
		str(item.get("name", selected.to_upper())),
		str(item.get("description", "Belum diketahui."))
	]

func _refresh_status() -> void:
	title_label.text = "%s %s" % [
		AuctionState.chapter2_day_name().to_upper(),
		AuctionState.chapter2_clock()
	]
	clock_label.text = "Batas kios: %s" % AuctionState.chapter2_deadline_label()
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
	button.custom_minimum_size = Vector2(0, 56)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	action_row.add_child(button)

func _travel_minutes(location_id: String) -> int:
	match location_id:
		"terminal_kota":
			return 30
		"alamat_sentana":
			return 25
		"pasar_tua":
			return 25
		_:
			return 15

func _rupiah(value: int) -> String:
	var raw := str(value)
	var formatted := ""
	while raw.length() > 3:
		formatted = "." + raw.substr(raw.length() - 3, 3) + formatted
		raw = raw.substr(0, raw.length() - 3)
	return "Rp" + raw + formatted
