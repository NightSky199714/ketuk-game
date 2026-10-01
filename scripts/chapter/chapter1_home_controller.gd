extends Control

var title_label: Label
var main_label: Label
var detail_label: Label
var book_label: Label
var next_button: Button
var stage: int = 0

func _ready() -> void:
	_build_ui()
	_show_stage()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#211a17")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 38)
	margin.add_theme_constant_override("margin_right", 38)
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_bottom", 48)
	add_child(margin)

	var root := VBoxContainer.new()
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 20)
	margin.add_child(root)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 29)
	root.add_child(title_label)

	main_label = Label.new()
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_label.custom_minimum_size = Vector2(0, 150)
	main_label.add_theme_font_size_override("font_size", 24)
	root.add_child(main_label)

	detail_label = Label.new()
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.custom_minimum_size = Vector2(0, 170)
	detail_label.add_theme_font_size_override("font_size", 19)
	root.add_child(detail_label)

	book_label = Label.new()
	book_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	book_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	book_label.custom_minimum_size = Vector2(0, 170)
	book_label.add_theme_font_size_override("font_size", 21)
	root.add_child(book_label)

	next_button = Button.new()
	next_button.custom_minimum_size = Vector2(260, 68)
	next_button.pressed.connect(_next)
	root.add_child(next_button)

func _show_stage() -> void:
	var lot02: Dictionary = AuctionState.lot_results.get("lot02", {})
	var lot03: Dictionary = AuctionState.lot_results.get("lot03", {})
	var owns_box := str(lot02.get("winner", "")) == "mc"
	var owns_camera := str(lot03.get("winner", "")) == "mc"

	if stage == 0:
		title_label.text = "MALAM — KEMBALI KE RUMAH"
		main_label.text = "Kamu mengeluarkan semua yang benar-benar kamu bawa pulang."
		var owned: Array[String] = []
		if owns_box:
			owned.append("Kotak Campuran")
		if owns_camera:
			owned.append("Kamera Analog")
		detail_label.text = "Barang milikmu: %s." % (", ".join(owned) if not owned.is_empty() else "tidak ada dari dua lot utama")
		book_label.text = "Uang tersisa: %s" % _rupiah(AuctionState.money)
		next_button.text = "BUKA BUKU"
		return

	if stage == 1:
		title_label.text = "BUKU"
		main_label.text = "Halaman kosong terasa berbeda setelah lelang pertama."
		if owns_box:
			detail_label.text = "Kamu belum tahu isi sebenarnya. Tapi keputusan Rp95.000 tadi tidak terasa sepenuhnya buta."
			book_label.text = "Rp95.000. Sepertinya tidak salah."
		else:
			detail_label.text = "Kotak Campuran bukan milikmu. Tidak ada alasan menulis seolah-olah kamu memilikinya."
			book_label.text = "Belum ada catatan untuk Lot 02."
		next_button.text = "TUTUP BUKU"
		return

	title_label.text = "BAB 1 SELESAI"
	main_label.text = "Hari ini kamu belum membuktikan bahwa kamu pandai menilai barang."
	detail_label.text = "Kamu hanya belajar bahwa melihat lebih teliti bisa mengubah keputusan."
	book_label.text = "Setiap tawaran punya harga."
	next_button.text = "MAIN DARI AWAL"
	AuctionState.finish_chapter1()

func _next() -> void:
	if stage < 2:
		stage += 1
		_show_stage()
		return

	get_tree().change_scene_to_file("res://scenes/chapter/chapter1_intro.tscn")

func _rupiah(value: int) -> String:
	var raw := str(value)
	var formatted := ""
	while raw.length() > 3:
		formatted = "." + raw.substr(raw.length() - 3, 3) + formatted
		raw = raw.substr(0, raw.length() - 3)
	return "Rp" + raw + formatted
