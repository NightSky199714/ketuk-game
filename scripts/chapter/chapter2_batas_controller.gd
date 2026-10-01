extends Control

var phase: String = "intro"
var title_label: Label
var clock_label: Label
var money_label: Label
var main_label: Label
var detail_label: Label
var choice_row: VBoxContainer
var continue_button: Button

func _ready() -> void:
	AuctionState.start_chapter2()
	_build_ui()
	_show_intro()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#1d1815")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 42)
	margin.add_theme_constant_override("margin_bottom", 42)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 16)
	margin.add_child(root)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 30)
	root.add_child(title_label)

	clock_label = Label.new()
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_label.add_theme_font_size_override("font_size", 19)
	root.add_child(clock_label)

	money_label = Label.new()
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	money_label.add_theme_font_size_override("font_size", 18)
	root.add_child(money_label)

	main_label = Label.new()
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_label.custom_minimum_size = Vector2(0, 170)
	main_label.add_theme_font_size_override("font_size", 24)
	root.add_child(main_label)

	detail_label = Label.new()
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.custom_minimum_size = Vector2(0, 230)
	detail_label.add_theme_font_size_override("font_size", 19)
	root.add_child(detail_label)

	choice_row = VBoxContainer.new()
	choice_row.add_theme_constant_override("separation", 10)
	root.add_child(choice_row)

	continue_button = Button.new()
	continue_button.visible = false
	continue_button.custom_minimum_size = Vector2(280, 68)
	continue_button.pressed.connect(_on_continue)
	root.add_child(continue_button)

func _show_intro() -> void:
	phase = "intro"
	_clear_choices()
	title_label.text = "BAB 2 — BATAS"
	_refresh_status()

	var owns_camera := _owns_camera()
	if not owns_camera:
		main_label.text = "Minggu sore. Deadline kios tetap berjalan."
		detail_label.text = "Kamera bukan milikmu. Tidak ada aset besar yang bisa langsung kamu cairkan dari lelang kemarin. Rp1.200.000 tetap harus dibayar sebelum 20:00."
		_add_choice("HADAPI DEADLINE", _route_no_camera)
		return

	main_label.text = "Kamera ada di depanmu. Masalahnya bukan lagi: berapa nilainya?"
	if AuctionState.camera_appraisal_seen:
		detail_label.text = "Pak Harun memperkirakan lensa punya nilai kolektor jauh di atas harga lelang. Tapi nilai di atas meja belum membayar tunggakan kios. Deadline: Minggu 20:00."
	else:
		detail_label.text = "Kamu tahu ada sesuatu yang berbeda pada lensa, tetapi tidak punya appraisal lengkap. Tunggakan kios tetap Rp1.200.000. Deadline: Minggu 20:00."

	_add_choice("JUAL SEKARANG — TOKO KAMERA Rp1.650.000", _route_camera_shop)
	_add_choice("CARI ADI — PEMBELI LENSA", _route_adi_start)
	_add_choice("KEJAR SENTANA — KOLEKTOR?", _route_sentana_start)

func _route_no_camera() -> void:
	AuctionState.advance_chapter2_time(240)
	phase = "route_a"
	_clear_choices()
	_refresh_status()
	title_label.text = "MINGGU — 20:00"
	main_label.text = "Waktu habis tanpa pembayaran penuh."
	detail_label.text = "Pak Arman datang setelah kios ditutup. Ia tidak membuat keributan. Papan nama kios dilepas pelan dan diserahkan kembali kepadamu. Kios tidak lagi bisa dipakai besok."
	AuctionState.finish_chapter2("A_KIOS_LOST")
	_show_finish("BAB 2 SELESAI")

func _route_camera_shop() -> void:
	AuctionState.advance_chapter2_time(30)
	AuctionState.money += 1650000
	AuctionState.camera_sale_status = "sold_full_1650"
	AuctionState.pay_kiosk(1200000)
	phase = "b1"
	_clear_choices()
	_refresh_status()
	title_label.text = "TOKO KAMERA — 16:30"
	main_label.text = "Rp1.650.000. Tunai sekarang."
	detail_label.text = "Toko mengambil body dan lensa. Kamu membayar Rp1.200.000 ke Pak Arman sebelum malam. Harga itu mungkin bukan harga tertinggi yang bisa didapat. Kios tetap buka."
	AuctionState.finish_chapter2("B1_SAFE_SALE")
	_show_finish("BATAS BUKAN BERARTI TAKUT")

func _route_adi_start() -> void:
	AuctionState.advance_chapter2_time(120)
	phase = "adi_warning"
	_clear_choices()
	_refresh_status()
	title_label.text = "MINGGU — 18:00"
	main_label.text = "Adi tertarik pada lensanya saja."
	detail_label.text = "Pesannya singkat: Rp2.100.000 untuk lensa, body dikembalikan. Tapi ia baru bisa bertemu Senin pagi. Dua jam tersisa menuju deadline kios."
	_add_choice("MINTA PERPANJANGAN KE PAK ARMAN", _route_adi_extension)
	_add_choice("BATAL — AMBIL PENAWARAN TOKO YANG TERLAMBAT", _route_late_shop_from_adi)

func _route_adi_extension() -> void:
	phase = "adi_extension"
	_clear_choices()
	_refresh_status()
	title_label.text = "MINGGU — 18:20"
	main_label.text = "Pak Arman tidak menghapus utang. Ia hanya memberi waktu."
	detail_label.text = "“Senin jam sepuluh. Lewat itu, saya anggap kamu tidak sanggup.” Tidak ada diskon. Tidak ada janji kedua."
	_add_choice("TEMUI ADI SENIN PAGI", _route_adi_finish)

func _route_adi_finish() -> void:
	AuctionState.chapter2_time_minutes = 24 * 60 + 9 * 60
	AuctionState.money += 2100000
	AuctionState.camera_sale_status = "lens_only_2100_body_returned"
	AuctionState.pay_kiosk(1200000)
	phase = "b2"
	_clear_choices()
	_refresh_status()
	title_label.text = "SENIN — 09:00"
	main_label.text = "Adi mengambil lensanya. Body dikembalikan."
	detail_label.text = "Rp2.100.000 masuk. Kamu menyerahkan tepat Rp1.200.000 kepada Pak Arman sebelum batas perpanjangan jam 10:00. Kios selamat. Body kamera masih di tanganmu."
	AuctionState.finish_chapter2("B2_ADI")
	_show_finish("BATAS BISA DINEGOSIASIKAN, BUKAN DIABAIKAN")

func _route_late_shop_from_adi() -> void:
	AuctionState.advance_chapter2_time(40)
	_finish_late_shop("Kamu kembali sebelum toko menutup. Karena waktu sempit, penawarannya turun.")

func _route_sentana_start() -> void:
	AuctionState.advance_chapter2_time(120)
	phase = "sentana_warning"
	_clear_choices()
	_refresh_status()
	title_label.text = "MINGGU — 18:00"
	main_label.text = "Nama Sentana ada. Orangnya belum ada."
	detail_label.text = "Nomor yang kamu dapat tidak menjawab. Seseorang bilang Sentana memang membeli barang kolektor, tapi tidak ada yang bisa memastikan ia akan melihat kamera hari ini. Dua jam tersisa."
	_add_choice("BERHENTI MENGEJAR — KEMBALI KE TOKO KAMERA", _route_sentana_return)
	_add_choice("LANJUT CARI SENTANA", _route_sentana_chase)

func _route_sentana_return() -> void:
	AuctionState.advance_chapter2_time(40)
	_finish_late_shop("Kamu kembali ke toko kamera. Pemilik toko melihat jam sebelum melihat kameramu.")

func _finish_late_shop(prefix: String) -> void:
	AuctionState.money += 1500000
	AuctionState.camera_sale_status = "sold_full_1500_late"
	AuctionState.pay_kiosk(1200000)
	phase = "b3a"
	_clear_choices()
	_refresh_status()
	title_label.text = "MINGGU — %s" % AuctionState.chapter2_clock()
	main_label.text = "Penawaran terlambat: Rp1.500.000."
	detail_label.text = "%s Kamu menerimanya. Lebih rendah Rp150.000 dari penawaran awal, tetapi kios tetap buka." % prefix
	AuctionState.finish_chapter2("B3A_LATE_RETURN")
	_show_finish("BERHENTI JUGA SEBUAH KEPUTUSAN")

func _route_sentana_chase() -> void:
	AuctionState.advance_chapter2_time(150)
	phase = "b3b"
	_clear_choices()
	_refresh_status()
	title_label.text = "MINGGU — 20:30"
	main_label.text = "Kamu menemukan alamat. Deadline sudah lewat."
	detail_label.text = "Saat kamu kembali, kios sudah ditutup. Pak Arman menyerahkan papan namanya dengan hati-hati. Sentana tidak pernah muncul malam itu."
	AuctionState.kiosk_saved = false
	AuctionState.finish_chapter2("B3B_CHASE_TOO_LONG")
	continue_button.text = "ESOK PAGI"
	continue_button.visible = true

func _show_sentana_after() -> void:
	phase = "sentana_after"
	AuctionState.chapter2_time_minutes = 24 * 60 + 9 * 60 + 10
	_refresh_status()
	title_label.text = "SENIN — 09:10"
	main_label.text = "Pesan masuk dari nomor yang kemarin tidak menjawab."
	detail_label.text = "Sentana ternyata nyata. Ia menawarkan Rp3.800.000 untuk kamera setelah melihat foto lensa. Angkanya lebih tinggi dari semua penawaran kemarin. Kios tetap sudah hilang."
	continue_button.text = "SELESAIKAN BAB 2"
	continue_button.visible = true

func _show_finish(line: String) -> void:
	continue_button.text = "SELESAI"
	continue_button.visible = true
	detail_label.text += "\n\n%s" % line

func _on_continue() -> void:
	if phase == "b3b":
		_show_sentana_after()
		return

	if phase == "sentana_after":
		phase = "end"
		continue_button.visible = false
		title_label.text = "BAB 2 — BATAS"
		main_label.text = "Rp3.800.000 tidak bisa membeli kembali jam 20:00 kemarin."
		detail_label.text = "Nilai tinggi dan keputusan tepat waktu bukan hal yang sama."
		return

	phase = "end"
	continue_button.visible = false
	title_label.text = "BAB 2 — BATAS"
	main_label.text = _route_summary()
	detail_label.text = _route_detail()

func _route_summary() -> String:
	match AuctionState.chapter2_route:
		"A_KIOS_LOST":
			return "Tidak ada barang yang bisa menghapus konsekuensi keputusan kemarin."
		"B1_SAFE_SALE":
			return "Kamu mengambil harga yang cukup, bukan harga tertinggi."
		"B2_ADI":
			return "Kamu membeli waktu dengan kepercayaan, lalu memenuhi batas baru."
		"B3A_LATE_RETURN":
			return "Kamu berhenti mengejar sebelum waktunya habis."
		_:
			return "Keputusan selesai. Konsekuensinya tetap berjalan."

func _route_detail() -> String:
	if AuctionState.kiosk_saved:
		return "Kios tetap buka. Masalah berikutnya tidak otomatis menjadi lebih mudah."
	return "Kios hilang. Cerita tetap berjalan."

func _refresh_status() -> void:
	clock_label.text = "Waktu: %s  |  Deadline kios: Minggu 20:00" % AuctionState.chapter2_clock()
	money_label.text = "Uang: %s  |  Tunggakan: %s" % [
		_rupiah(AuctionState.money),
		_rupiah(maxi(AuctionState.kiosk_arrears - AuctionState.kiosk_paid, 0))
	]

func _owns_camera() -> bool:
	var lot03: Dictionary = AuctionState.lot_results.get("lot03", {})
	return str(lot03.get("winner", "")) == "mc" and AuctionState.camera_sale_status.is_empty()

func _add_choice(label: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(0, 68)
	button.pressed.connect(callback)
	choice_row.add_child(button)

func _clear_choices() -> void:
	for child in choice_row.get_children():
		child.queue_free()
	continue_button.visible = false

func _rupiah(value: int) -> String:
	var raw := str(value)
	var formatted := ""
	while raw.length() > 3:
		formatted = "." + raw.substr(raw.length() - 3, 3) + formatted
		raw = raw.substr(0, raw.length() - 3)
	return "Rp" + raw + formatted
