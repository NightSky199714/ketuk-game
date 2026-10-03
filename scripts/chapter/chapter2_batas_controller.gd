extends Control

const MAP_DATA_PATH := "res://data/chapter/chapter2_batas_map.json"
const ICON_HOME = preload("res://assets/ui/icons/home.svg")
const ICON_CAMERA = preload("res://assets/ui/icons/camera.svg")
const ICON_SHOP = preload("res://assets/ui/icons/shop.svg")
const ICON_MARKET = preload("res://assets/ui/icons/market.svg")
const ICON_PIN = preload("res://assets/ui/icons/pin.svg")
const ICON_BOOK = preload("res://assets/ui/icons/book.svg")
const ICON_BOX = preload("res://assets/ui/icons/box.svg")

var map_data: Dictionary = {}
var current_location_id: String = "rumah"

@onready var title_label: Label = $Margin/Root/Scroll/Content/HeaderPanel/HeaderMargin/HeaderStack/TitleLabel
@onready var clock_label: Label = $Margin/Root/Scroll/Content/HeaderPanel/HeaderMargin/HeaderStack/ClockLabel
@onready var money_label: Label = $Margin/Root/Scroll/Content/HeaderPanel/HeaderMargin/HeaderStack/MoneyLabel
@onready var clue_label: Label = $Margin/Root/Scroll/Content/CluePanel/ClueMargin/ClueLabel
@onready var inventory_grid: GridContainer = $Margin/Root/Scroll/Content/InventoryPanel/InventoryMargin/InventoryStack/InventoryGrid
@onready var inventory_detail: Label = $Margin/Root/Scroll/Content/InventoryPanel/InventoryMargin/InventoryStack/InventoryDetail
@onready var map_row: GridContainer = $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow
@onready var location_label: Label = $Margin/Root/Scroll/Content/LocationPanel/LocationMargin/LocationStack/LocationLabel
@onready var location_description: Label = $Margin/Root/Scroll/Content/LocationPanel/LocationMargin/LocationStack/LocationDescription
@onready var response_label: Label = $Margin/Root/Scroll/Content/ResponsePanel/ResponseMargin/ResponseLabel
@onready var action_row: GridContainer = $Margin/Root/ActionDock/ActionMargin/ActionRow
@onready var map_view_button: Button = $Margin/Root/ViewBar/MapViewButton
@onready var bag_view_button: Button = $Margin/Root/ViewBar/BagViewButton
@onready var clue_panel: PanelContainer = $Margin/Root/Scroll/Content/CluePanel
@onready var inventory_caption: Label = $Margin/Root/Scroll/Content/InventoryCaption
@onready var inventory_panel: PanelContainer = $Margin/Root/Scroll/Content/InventoryPanel
@onready var map_caption: Label = $Margin/Root/Scroll/Content/MapCaption
@onready var map_panel: PanelContainer = $Margin/Root/Scroll/Content/MapPanel
@onready var location_panel: PanelContainer = $Margin/Root/Scroll/Content/LocationPanel
@onready var response_panel: PanelContainer = $Margin/Root/Scroll/Content/ResponsePanel
@onready var menu_button: Button = $MenuButton
var location_buttons: Dictionary = {}

func _ready() -> void:
	if not AuctionState.chapter2_started:
		AuctionState.start_chapter2()
	_load_map()
	_wire_ui()
	current_location_id = str(AuctionState.world_flags.get("world_location", "rumah"))
	if not AuctionState.chapter2_known_places.has(current_location_id):
		current_location_id = "rumah"
	_show_location(current_location_id, false)
	if not bool(AuctionState.world_flags.get("world_opening_seen", false)):
		_show_opening()
		AuctionState.world_flags["world_opening_seen"] = true

func _wire_ui() -> void:
	location_buttons = {
		"rumah": $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow/RumahButton,
		"toko_kamera": $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow/TokoKameraButton,
		"warung_ratna": $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow/WarungRatnaButton,
		"pak_arman": $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow/PakArmanButton,
		"bengkel_umum": $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow/BengkelButton,
		"pasar_tua": $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow/PasarTuaButton,
		"kedai_foto": $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow/KedaiFotoButton,
		"terminal_kota": $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow/TerminalButton,
		"alamat_sentana": $Margin/Root/Scroll/Content/MapPanel/MapMargin/MapRow/SentanaButton
	}

	var location_icons := {
		"rumah": ICON_HOME,
		"toko_kamera": ICON_CAMERA,
		"warung_ratna": ICON_SHOP,
		"pak_arman": ICON_SHOP,
		"bengkel_umum": ICON_SHOP,
		"pasar_tua": ICON_MARKET,
		"kedai_foto": ICON_CAMERA,
		"terminal_kota": ICON_PIN,
		"alamat_sentana": ICON_PIN
	}

	for location_id in location_buttons.keys():
		var button: Button = location_buttons[location_id]
		button.icon = location_icons.get(str(location_id), ICON_PIN)
		button.add_theme_constant_override("icon_max_width", 22)
		button.expand_icon = true
		var captured_id := str(location_id)
		button.pressed.connect(func(): _travel_to(captured_id))

	map_view_button.pressed.connect(_show_map_view)
	bag_view_button.pressed.connect(_show_bag_view)
	menu_button.pressed.connect(_return_to_menu)
	_show_map_view()
	_refresh_status()
	_autosave()
	_refresh_inventory()
	_refresh_map()

func _show_map_view() -> void:
	clue_panel.visible = false
	inventory_caption.visible = false
	inventory_panel.visible = false
	map_caption.visible = true
	map_panel.visible = true
	location_panel.visible = true
	response_panel.visible = true
	map_view_button.theme_type_variation = &"PrimaryButton"
	bag_view_button.theme_type_variation = &""

func _show_bag_view() -> void:
	clue_panel.visible = true
	inventory_caption.visible = true
	inventory_panel.visible = true
	map_caption.visible = false
	map_panel.visible = false
	location_panel.visible = false
	response_panel.visible = false
	map_view_button.theme_type_variation = &""
	bag_view_button.theme_type_variation = &"PrimaryButton"

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

func _show_opening() -> void:
	title_label.text = "MINGGU SORE"
	response_label.text = "Minggu sore. Nota tunggakan masih terselip di meja."
	clue_label.text = ""
	_refresh_actions()

func _travel_to(location_id: String) -> void:
	if not AuctionState.chapter2_known_places.has(location_id):
		return
	if location_id == current_location_id:
		_show_location(location_id, false)
		return

	AuctionState.advance_chapter2_time(_travel_minutes(location_id))
	current_location_id = location_id
	AuctionState.world_flags["world_location"] = location_id
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

	var is_open := _location_is_open(location_id)
	var closed_text := _location_closed_text(location_id)

	if moved:
		response_label.text = "Kamu tiba di %s." % str(location.get("label", location_id))
	else:
		response_label.text = ""

	if not is_open and not closed_text.is_empty():
		if response_label.text.is_empty():
			response_label.text = closed_text
		else:
			response_label.text += "\n\n" + closed_text

	_refresh_status()
	_autosave()
	_refresh_inventory()
	_refresh_map()
	_refresh_actions()
	_autosave()

func _refresh_actions() -> void:
	_clear_actions()

	if not _location_is_open(current_location_id):
		return

	if current_location_id == "toko_kamera":
		var offer_day := str(AuctionState.world_flags.get("harun_offer_day", ""))
		if AuctionState.chapter2_pending_offer > 0 and not offer_day.is_empty():
			if offer_day != AuctionState.chapter2_day_name():
				AuctionState.chapter2_pending_offer = 0

	match current_location_id:
		"rumah":
			_build_home_actions()
		"toko_kamera":
			_add_action("BICARA DENGAN PAK HARUN", _talk_harun)
			_add_show_item_action()
			if AuctionState.chapter2_pending_offer > 0 and AuctionState.has_inventory_item("camera"):
				_add_action(
					"TERIMA %s" % _rupiah(AuctionState.chapter2_pending_offer),
					_accept_harun_offer
				)
		"warung_ratna":
			_add_action("BICARA DENGAN BU RATNA", _talk_ratna)
			_add_show_item_action()
		"pak_arman":
			_add_action("BICARA DENGAN PAK ARMAN", _talk_arman)
			_add_show_item_action()
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
			_add_show_item_action()
		"terminal_kota":
			_build_terminal_actions()
			_add_show_item_action()
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
	if AuctionState.selected_inventory_item == "book":
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
		"pak_arman":
			_show_item_to_arman(item_id)
		"kedai_foto":
			_show_item_to_photo_shop(item_id)
		"terminal_kota":
			_show_item_to_terminal(item_id)
		_:
			response_label.text = "Tidak ada reaksi khusus terhadap barang itu di sini."

	_refresh_inventory()
	_refresh_actions()
	_autosave()

func _show_item_to_arman(item_id: String) -> void:
	var memory_id := "shown_%s" % item_id
	if AuctionState.npc_remembers("pak_arman", memory_id):
		response_label.text = "Barang itu sudah pernah dilihat di sini. Tidak ada tambahan baru."
		return
	AuctionState.remember_npc_event("pak_arman", memory_id)
	AuctionState.advance_chapter2_time(5)
	if item_id == "camera":
		response_label.text = "Pak Arman melihat kamera itu sekilas. \"Saya bukan pedagang kamera. Kalau ada uang untuk kios, saya terima uangnya.\""
	elif item_id == "mixed_box":
		response_label.text = "Pak Arman menggeleng. \"Saya nggak tahu isi kotakmu. Itu bukan urusan sewa kios.\""
	else:
		response_label.text = "Pak Arman tidak punya komentar yang berguna soal barang itu."
	_refresh_status()
	_autosave()

func _talk_photo_shop() -> void:
	AuctionState.advance_chapter2_time(5)
	response_label.text = "Penjaga kedai sedang merapikan amplop foto dan baterai lama di belakang etalase."
	_refresh_status()
	_autosave()

func _show_item_to_photo_shop(item_id: String) -> void:
	var memory_id := "shown_%s" % item_id
	if AuctionState.npc_remembers("penjaga_foto", memory_id):
		response_label.text = "Barang itu sudah pernah dilihat di sini. Tidak ada tambahan baru."
		return
	AuctionState.remember_npc_event("penjaga_foto", memory_id)
	AuctionState.advance_chapter2_time(10)

	if item_id == "camera" and AuctionState.has_inventory_item("camera"):
		AuctionState.chapter2_leads["adi"] = true
		AuctionState.hear_rumor(
			"adi_lens_buyer",
			"Katanya ada orang bernama Adi yang kadang membeli lensa lama.",
			"Penjaga Kedai Foto"
		)
		if AuctionState.chapter2_day_name() == "Minggu":
			AuctionState.chapter2_leads["adi_waiting"] = true
			response_label.text = "Penjaga melihat kameramu lebih lama pada bagian lensa.\n\n\"Ada orang namanya Adi yang kadang cari lensa lama. Hari ini nggak kelihatan. Kalau datang lagi, biasanya pagi—mungkin besok.\""
		else:
			response_label.text = "Penjaga melihat kameramu lebih lama pada bagian lensa.\n\n\"Ada orang namanya Adi yang kadang cari lensa lama. Kalau dia datang, biasanya pagi.\""
		clue_label.text = ""
	elif item_id == "sentana_photo":
		response_label.text = "Penjaga melihat foto poster itu. \"Nama Sentana pernah saya dengar, tapi bukan dari pelanggan tetap sini.\""
	else:
		response_label.text = "Penjaga kedai mengembalikan barangmu. \"Kalau bukan urusan kamera atau foto, saya nggak berani komentar.\""

	_refresh_status()
	_autosave()

func _show_item_to_terminal(item_id: String) -> void:
	var memory_id := "shown_%s" % item_id
	if AuctionState.npc_remembers("terminal", memory_id):
		response_label.text = "Barang itu sudah pernah dilihat di sini. Tidak ada tambahan baru."
		return
	AuctionState.remember_npc_event("terminal", memory_id)
	AuctionState.advance_chapter2_time(10)

	if item_id == "sentana_photo":
		AuctionState.start_sentana_access()
		AuctionState.chapter2_leads["sentana"] = true
		AuctionState.record_sentana_invitation_lead(
			"terminal_poster",
			"Seorang sopir Terminal Kota mengenali nama Sentana pada poster."
		)
		AuctionState.hear_rumor(
			"sentana_drivers",
			"Beberapa orang terminal merasa pernah mendengar nama Sentana.",
			"Terminal Kota"
		)
		response_label.text = "Seorang sopir menatap foto posternya. \"Sentana... kayak pernah dengar. Coba duduk dulu, mungkin ada yang ingat alamatnya.\""
		clue_label.text = ""
	elif item_id == "camera":
		response_label.text = "Beberapa orang melihat kamera itu, lalu kembali ke urusan masing-masing. Tidak ada yang memberi informasi berguna."
	else:
		response_label.text = "Barang itu tidak memicu percakapan yang berarti di terminal."

	_refresh_status()
	_autosave()

func _show_item_to_harun(item_id: String) -> void:
	AuctionState.advance_chapter2_time(10)
	if item_id == "camera" and AuctionState.has_inventory_item("camera"):
		var offer := 1650000
		if AuctionState.chapter2_time_minutes >= 18 * 60:
			offer = 1500000
		AuctionState.chapter2_pending_offer = offer
		AuctionState.world_flags["harun_offer_day"] = AuctionState.chapter2_day_name()
		AuctionState.chapter2_leads["adi"] = true
		AuctionState.chapter2_known_places["kedai_foto"] = true
		AuctionState.hear_rumor(
			"adi_lens_buyer",
			"Katanya ada orang bernama Adi yang kadang membeli lensa lama.",
			"Pak Harun"
		)
		response_label.text = "Pak Harun memeriksa kamera.\n\n\"Kalau saya ambil sekarang, %s.\"\n\nIa menyebut seseorang bernama Adi yang kadang membeli lensa tanpa bodynya." % _rupiah(offer)
		clue_label.text = ""
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
	_autosave()

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
	clue_label.text = ""
	_refresh_status()
	_autosave()
	_refresh_inventory()
	_refresh_actions()

func _talk_ratna() -> void:
	AuctionState.advance_chapter2_time(10)
	response_label.text = "Bu Ratna sedang melayani dua orang. Obrolan di warung berpindah-pindah dari harga beras sampai orang kota."
	_refresh_status()
	_autosave()

func _show_item_to_ratna(item_id: String) -> void:
	var memory_id := "shown_%s" % item_id
	if AuctionState.npc_remembers("bu_ratna", memory_id):
		response_label.text = "Barang itu sudah pernah dilihat di sini. Tidak ada tambahan baru."
		return
	AuctionState.remember_npc_event("bu_ratna", memory_id)
	AuctionState.advance_chapter2_time(10)
	if item_id == "camera":
		AuctionState.chapter2_leads["sentana"] = true
		AuctionState.chapter2_known_places["terminal_kota"] = true
		AuctionState.hear_rumor(
			"sentana_name",
			"Katanya ada nama Sentana yang beredar di antara sopir-sopir kota.",
			"Bu Ratna"
		)
		response_label.text = "Bu Ratna melihat tas kameramu. \"Pernah dengar nama Sentana dari sopir-sopir kota. Katanya suka barang aneh. Nggak tahu orangnya yang mana.\""
		clue_label.text = ""
	elif item_id == "mixed_box":
		response_label.text = "Bu Ratna mengetuk sisi kotaknya. \"Berat. Tapi kalau macet begini jangan dipaksa pakai pisau dapur.\""
	else:
		response_label.text = "Bu Ratna melihatnya sebentar. \"Aku bisa jual makanan. Kalau barang begini, aku cuma bisa ikut penasaran.\""

func _talk_craftsman() -> void:
	AuctionState.advance_chapter2_time(10)
	response_label.text = "Pengrajin itu sedang memperbaiki engsel lemari. Meja kerjanya penuh ragum, tang, dan alat kecil."
	_refresh_status()
	_autosave()

func _show_item_to_craftsman(item_id: String) -> void:
	var memory_id := "shown_%s" % item_id
	if AuctionState.npc_remembers("pengrajin", memory_id):
		response_label.text = "Barang itu sudah pernah dilihat di sini. Tidak ada tambahan baru."
		return
	AuctionState.remember_npc_event("pengrajin", memory_id)
	AuctionState.advance_chapter2_time(20)
	if item_id == "mixed_box":
		var box := AuctionState.get_inventory_item("mixed_box")
		if str(box.get("state", "")) == "closed":
			response_label.text = "Ia menjepit bagian luar kotak dengan kain, lalu bekerja pada penguncinya beberapa menit.\n\n\"Bukan terkunci. Cuma mekanismenya macet.\"\n\nTutup akhirnya terbuka."
			AuctionState.open_mixed_box()
			AuctionState.selected_inventory_item = ""
			clue_label.text = ""
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
		clue_label.text = ""
	else:
		response_label.text = "\"Kalau ada uangnya, bayar. Kalau belum, batasnya tetap,\" kata Pak Arman."
	_refresh_status()
	_autosave()

func _pay_arman() -> void:
	var remaining := maxi(AuctionState.kiosk_arrears - AuctionState.kiosk_paid, 0)
	if remaining <= 0 or AuctionState.money < remaining:
		return

	AuctionState.pay_kiosk(remaining)
	AuctionState.kiosk_saved = true
	AuctionState.world_flags["kiosk_resolved"] = true
	response_label.text = "Pak Arman menghitung uangnya. Tunggakan lunas."
	clue_label.text = ""
	_refresh_status()
	_autosave()
	_refresh_actions()

func _build_adi_actions() -> void:
	_add_action("BICARA DENGAN PENJAGA", _talk_photo_shop)

	if (
		AuctionState.chapter2_leads.has("adi")
		and AuctionState.camera_lens_available()
		and _adi_present()
	):
		_add_action("BICARA DENGAN ADI", _meet_adi)

func _check_adi_sunday() -> void:
	if AuctionState.chapter2_time_minutes < 18 * 60:
		AuctionState.chapter2_time_minutes = 18 * 60
	else:
		AuctionState.advance_chapter2_time(15)

	AuctionState.chapter2_leads["adi_waiting"] = true
	response_label.text = "Adi tidak ada. Pemilik kedai menunjukkan pesan singkat: lensa saja, Rp2.100.000, Senin pagi."
	clue_label.text = ""
	_refresh_status()
	_autosave()
	_refresh_actions()
	_check_deadline_event()

func _wait_until_monday() -> void:
	AuctionState.chapter2_time_minutes = 24 * 60 + 8 * 60 + 40
	response_label.text = "Pagi datang."
	_refresh_status()
	_autosave()
	_refresh_actions()
	_check_deadline_event()

func _meet_adi() -> void:
	if not AuctionState.camera_lens_available():
		response_label.text = "Lensanya sudah tidak ada untuk dijual."
		_refresh_inventory()
		_refresh_actions()
		return

	AuctionState.advance_chapter2_time(20)

	if not AuctionState.sell_camera_lens_to_adi():
		response_label.text = "Transaksi itu sudah selesai."
		_refresh_inventory()
		_refresh_actions()
		return

	response_label.text = "Adi membeli lensanya seharga Rp2.100.000. Body dikembalikan."
	clue_label.text = ""
	_refresh_status()
	_autosave()
	_refresh_inventory()
	_refresh_actions()

func _build_terminal_actions() -> void:
	_add_action("DUDUK DAN MENDENGAR", _ask_terminal)

func _ask_terminal() -> void:
	AuctionState.advance_chapter2_time(35)

	if not AuctionState.chapter2_leads.has("sentana"):
		response_label.text = "Kamu duduk cukup lama. Obrolannya berpindah dari trayek, harga bensin, sampai penumpang yang tertinggal barang. Tidak ada sesuatu yang jelas berguna."
		_refresh_status()
		_autosave()
		_check_deadline_event()
		return

	if not AuctionState.chapter2_leads.has("sentana_address"):
		AuctionState.chapter2_leads["sentana_address"] = true
		AuctionState.chapter2_known_places["alamat_sentana"] = true
		AuctionState.hear_rumor(
			"sentana_address",
			"Seorang sopir memberi satu alamat yang mungkin terkait Sentana.",
			"Terminal Kota"
		)
		response_label.text = "Setelah beberapa percakapan, seorang sopir akhirnya memberi patokan sebuah alamat yang mungkin terkait nama Sentana. Ia sendiri tidak yakin."

		if (
			AuctionState.sentana_access_started
			and AuctionState.has_inventory_item("sentana_photo")
			and AuctionState.sentana_invitation_leads.has("terminal_poster")
		):
			AuctionState.record_sentana_invitation_lead(
				"terminal_address",
				"Alamat kota yang disebut sopir terkait dengan jalur distribusi undangan Sentana."
			)
			response_label.text += "\n\nSopir lain melihat fotonya lagi. \"Kalau poster ini asli, alamat itu bukan rumah orangnya. Dulu saya pernah antar amplop acara ke sana.\""

		clue_label.text = ""
	else:
		response_label.text = "Kamu tidak mendapat tambahan yang lebih pasti dari alamat yang sudah dicatat."

		if (
			AuctionState.sentana_access_started
			and AuctionState.has_inventory_item("sentana_photo")
			and AuctionState.sentana_invitation_leads.has("terminal_poster")
			and not AuctionState.sentana_invitation_leads.has("terminal_address")
		):
			AuctionState.record_sentana_invitation_lead(
				"terminal_address",
				"Alamat kota yang disebut sopir terkait dengan jalur distribusi undangan Sentana."
			)
			response_label.text = "Kamu menyebut alamat yang sudah pernah dicatat. Seorang sopir melihat foto poster itu, lalu mengangguk.\n\n\"Iya. Kalau poster ini asli, alamat itu bukan rumah orangnya. Dulu saya pernah antar amplop acara ke sana.\""

	_refresh_status()
	_autosave()
	_refresh_map()
	_refresh_actions()
	_check_deadline_event()

func _build_sentana_actions() -> void:
	if not AuctionState.chapter2_leads.has("sentana_address"):
		return

	if AuctionState.has_sentana_invitation():
		_add_action("PERIKSA UNDANGAN", _review_sentana_invitation)
		return

	_add_action("DATANGI ALAMAT", _search_sentana_address)

	if (
		AuctionState.sentana_access_started
		and AuctionState.sentana_invitation_leads.has("terminal_address")
		and AuctionState.selected_inventory_item == "sentana_photo"
		and AuctionState.has_inventory_item("sentana_photo")
	):
		_add_action("TUNJUKKAN FOTO POSTER", _present_sentana_photo_at_address)

func _present_sentana_photo_at_address() -> void:
	if not AuctionState.sentana_access_started:
		return
	if not AuctionState.sentana_invitation_leads.has("terminal_address"):
		return
	if not AuctionState.has_inventory_item("sentana_photo"):
		return

	AuctionState.advance_chapter2_time(20)
	var granted := AuctionState.grant_sentana_invitation("Meja depan — alamat kota")

	if granted:
		response_label.text = "Perempuan di meja depan melihat foto poster cukup lama, lalu memeriksa nomor kecil di sudutnya.\n\n\"Poster pasar,\" katanya. \"Undangannya memang diambil lewat sini.\"\n\nIa membuka laci, mencocokkan catatan, lalu menyerahkan satu amplop tebal dengan nama acara yang sama."
		clue_label.text = ""
	else:
		response_label.text = "Tidak ada tambahan baru dari foto itu."

	_refresh_status()
	_refresh_inventory()
	_refresh_actions()
	_autosave()
	_check_deadline_event()

func _review_sentana_invitation() -> void:
	response_label.text = "Amplop undangan masih ada di tasmu. Nama acara pada kartu di dalamnya sama dengan poster Pasar Tua."
	clue_label.text = ""
	_refresh_inventory()
	_autosave()

func _search_sentana_address() -> void:
	AuctionState.advance_chapter2_time(150)
	AuctionState.chapter2_leads["sentana_chased"] = true
	AuctionState.verify_rumor(
		"sentana_address",
		"Alamat yang diberikan sopir memang ada, tetapi belum membuktikan siapa yang terkait dengannya."
	)
	if AuctionState.sentana_access_started:
		response_label.text = "Alamatnya nyata, tetapi bukan rumah Sentana. Ada meja depan dan beberapa kotak arsip; tanpa petunjuk tambahan, tidak ada yang mau menjelaskan hubungan tempat ini dengan acara di poster."
	else:
		response_label.text = "Alamatnya nyata. Sentana tidak ada di sana."
	clue_label.text = ""
	_refresh_status()
	_autosave()
	_check_deadline_event()

func _enter_old_market() -> void:
	AuctionState.world_flags["world_location"] = "pasar_tua"
	_autosave()
	get_tree().change_scene_to_file("res://scenes/chapter/chapter3_orang_yang_tepat.tscn")

func _wait_one_hour() -> void:
	AuctionState.advance_chapter2_time(60)
	response_label.text = "Satu jam lewat."
	_refresh_status()
	_autosave()
	_refresh_actions()
	_check_deadline_event()

func _check_deadline_event() -> void:
	if not AuctionState.resolve_kiosk_deadline_if_needed():
		return

	response_label.text += "\n\nSaat batas lewat tanpa pembayaran penuh, Pak Arman menutup kios dan mengembalikan papan namanya."
	clue_label.text = ""
	_refresh_actions()
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
	_refresh_actions()
	_show_bag_view()

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

	if AuctionState.inventory.is_empty():
		inventory_detail.text = "Inventory kosong."
		return

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

func _adi_present() -> bool:
	if AuctionState.chapter2_day_name() != "Senin":
		return false

	var minute_of_day := AuctionState.chapter2_time_minutes % (24 * 60)
	return minute_of_day >= 8 * 60 + 30 and minute_of_day < 10 * 60

func _location_is_open(location_id: String) -> bool:
	var locations: Dictionary = map_data.get("locations", {})
	var location: Dictionary = locations.get(location_id, {})
	if location.is_empty():
		return true

	var schedule: Dictionary = location.get("schedule", {})
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

func _location_closed_text(location_id: String) -> String:
	var locations: Dictionary = map_data.get("locations", {})
	var location: Dictionary = locations.get(location_id, {})
	if location.is_empty():
		return ""

	var schedule: Dictionary = location.get("schedule", {})
	return str(schedule.get("closed_text", ""))

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
			button.theme_type_variation = &"SelectedButton"
		else:
			button.theme_type_variation = &""
		button.text = label

func _clear_actions() -> void:
	for child in action_row.get_children():
		child.queue_free()

func _add_action(label: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.tooltip_text = label
	button.clip_text = true
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


func _autosave() -> void:
	if AuctionState.chapter2_started:
		SaveManager.save_game("res://scenes/chapter/chapter2_batas.tscn")

func _return_to_menu() -> void:
	_autosave()
	get_tree().change_scene_to_file("res://scenes/system/main_menu.tscn")
