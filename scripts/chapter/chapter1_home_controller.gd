extends Control

const DISCOVERY_DATA_PATH := "res://data/discovery/prototype_discovery.json"

var discovery_data: Dictionary = {}
var inspected: Dictionary = {}
var inspect_count: int = 0
var phase: String = "home"

var title_label: Label
var main_label: Label
var detail_label: Label
var book_label: Label
var next_button: Button
var object_row: HBoxContainer
var finish_inspect_button: Button

func _ready() -> void:
	_load_discovery_data()
	_build_ui()
	_show_home()

func _load_discovery_data() -> void:
	if not FileAccess.file_exists(DISCOVERY_DATA_PATH):
		return

	var file := FileAccess.open(DISCOVERY_DATA_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		discovery_data = parsed

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
	root.add_theme_constant_override("separation", 18)
	margin.add_child(root)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 29)
	root.add_child(title_label)

	main_label = Label.new()
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_label.custom_minimum_size = Vector2(0, 135)
	main_label.add_theme_font_size_override("font_size", 24)
	root.add_child(main_label)

	detail_label = Label.new()
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.custom_minimum_size = Vector2(0, 175)
	detail_label.add_theme_font_size_override("font_size", 19)
	root.add_child(detail_label)

	object_row = HBoxContainer.new()
	object_row.alignment = BoxContainer.ALIGNMENT_CENTER
	object_row.add_theme_constant_override("separation", 8)
	object_row.visible = false
	root.add_child(object_row)

	for object_id in ["coaster", "lighter", "adapter"]:
		var button := Button.new()
		button.custom_minimum_size = Vector2(175, 66)
		button.text = _object_label(object_id)
		var captured_id: String = object_id
		button.pressed.connect(func(): _inspect_object(captured_id))
		object_row.add_child(button)

	book_label = Label.new()
	book_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	book_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	book_label.custom_minimum_size = Vector2(0, 150)
	book_label.add_theme_font_size_override("font_size", 21)
	root.add_child(book_label)

	finish_inspect_button = Button.new()
	finish_inspect_button.text = "SELESAI MEMERIKSA"
	finish_inspect_button.custom_minimum_size = Vector2(260, 64)
	finish_inspect_button.visible = false
	finish_inspect_button.disabled = true
	finish_inspect_button.pressed.connect(_finish_inspection)
	root.add_child(finish_inspect_button)

	next_button = Button.new()
	next_button.custom_minimum_size = Vector2(260, 68)
	next_button.pressed.connect(_next)
	root.add_child(next_button)

func _show_home() -> void:
	phase = "home"
	object_row.visible = false
	finish_inspect_button.visible = false
	next_button.visible = true

	var lot02: Dictionary = AuctionState.lot_results.get("lot02", {})
	var lot03: Dictionary = AuctionState.lot_results.get("lot03", {})
	var owns_box := str(lot02.get("winner", "")) == "mc"
	var owns_camera := str(lot03.get("winner", "")) == "mc"

	title_label.text = "MALAM — KEMBALI KE RUMAH"
	main_label.text = "Kamu mengeluarkan semua yang benar-benar kamu bawa pulang."

	var owned_text := "tidak ada dari dua lot utama"
	if owns_box and owns_camera:
		owned_text = "Kotak Campuran, Kamera Analog"
	elif owns_box:
		owned_text = "Kotak Campuran"
	elif owns_camera:
		owned_text = "Kamera Analog"

	detail_label.text = "Barang milikmu: %s." % owned_text
	if AuctionState.camera_appraisal_seen:
		detail_label.text += "\nKamu juga membawa pulang satu informasi baru tentang kamera: body biasa, lensa belum biasa."

	book_label.text = "Uang tersisa: %s" % _rupiah(AuctionState.money)
	next_button.text = "BUKA KOTAK" if owns_box else "BUKA BUKU"

func _show_box() -> void:
	phase = "box"
	next_button.visible = false
	object_row.visible = true
	finish_inspect_button.visible = true
	finish_inspect_button.disabled = inspect_count == 0

	var lot_data: Dictionary = discovery_data.get("lot02", {})
	title_label.text = "KOTAK CAMPURAN"
	main_label.text = str(
		lot_data.get(
			"open_text",
			"Kamu membuka kotak dan mengeluarkan isinya satu per satu."
		)
	)
	detail_label.text = str(
		lot_data.get(
			"selection_reason",
			"Beberapa benda meninggalkan pertanyaan yang belum selesai."
		)
	)
	book_label.text = "Pilih benda yang ingin kamu lihat lebih dekat."

func _inspect_object(object_id: String) -> void:
	AuctionState.discovery_target = object_id
	var object_data := _get_object_data(object_id)
	if object_data.is_empty():
		return

	if not inspected.has(object_id):
		inspected[object_id] = true
		inspect_count += 1

	detail_label.text = "%s — %s" % [
		str(object_data.get("label", "OBJEK")),
		str(object_data.get("observation", "Tidak ada yang jelas."))
	]
	book_label.text = "CATATAN SEMENTARA\n%s" % str(
		object_data.get("note", "Belum ada kesimpulan.")
	)

	AuctionState.discovery_notes[object_id] = {
		"observation": str(object_data.get("observation", "")),
		"note": str(object_data.get("note", "")),
		"status": "unresolved"
	}

	finish_inspect_button.disabled = false
	finish_inspect_button.text = "DALAMI %s" % _object_label(object_id)

func _finish_inspection() -> void:
	_show_book()

func _show_book() -> void:
	phase = "book"
	object_row.visible = false
	finish_inspect_button.visible = false
	next_button.visible = true

	var lot02: Dictionary = AuctionState.lot_results.get("lot02", {})
	var owns_box := str(lot02.get("winner", "")) == "mc"

	title_label.text = "BUKU"
	main_label.text = "Halaman kosong terasa berbeda setelah lelang pertama."

	if owns_box:
		var lot02_amount := int(lot02.get("amount", 95000))
		if inspect_count > 0:
			detail_label.text = "Kamu sudah melihat isi kotaknya sendiri. Belum ada jawaban final, tapi keputusanmu tidak sepenuhnya buta."
		else:
			detail_label.text = "Kotaknya milikmu, tetapi kamu belum memeriksa isinya lebih jauh."

		if lot02_amount == 95000:
			book_label.text = "Rp95.000. Sepertinya tidak salah."
		else:
			book_label.text = "%s. Belum tahu apakah salah." % _rupiah(lot02_amount)
	else:
		detail_label.text = "Kotak Campuran bukan milikmu. Tidak ada alasan menulis seolah-olah kamu memilikinya."
		book_label.text = "Belum ada catatan untuk Lot 02."

	next_button.text = "TUTUP BUKU"

func _show_end() -> void:
	phase = "end"
	object_row.visible = false
	finish_inspect_button.visible = false
	next_button.visible = true

	title_label.text = "BAB 1 SELESAI"
	main_label.text = "Hari ini kamu belum membuktikan bahwa kamu pandai menilai barang."
	detail_label.text = "Kamu hanya belajar bahwa melihat lebih teliti bisa mengubah keputusan."
	book_label.text = "Setiap tawaran punya harga."
	next_button.text = "LANJUT BAB 2"
	AuctionState.finish_chapter1()

func _next() -> void:
	if phase == "home":
		var lot02: Dictionary = AuctionState.lot_results.get("lot02", {})
		var owns_box := str(lot02.get("winner", "")) == "mc"
		if owns_box:
			_show_box()
		else:
			_show_book()
		return

	if phase == "book":
		_show_end()
		return

	if phase == "end":
		get_tree().change_scene_to_file("res://scenes/chapter/chapter2_batas.tscn")

func _get_object_data(object_id: String) -> Dictionary:
	var lot_data: Dictionary = discovery_data.get("lot02", {})
	var objects: Array = lot_data.get("objects", [])
	for value in objects:
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var object_data: Dictionary = value
		if str(object_data.get("id", "")) == object_id:
			return object_data
	return {}

func _object_label(object_id: String) -> String:
	var object_data := _get_object_data(object_id)
	if object_data.is_empty():
		match object_id:
			"coaster":
				return "TATAKAN"
			"lighter":
				return "KOREK"
			"adapter":
				return "ADAPTOR"
			_:
				return object_id.to_upper()
	return str(object_data.get("label", object_id)).to_upper()

func _rupiah(value: int) -> String:
	var raw := str(value)
	var formatted := ""
	while raw.length() > 3:
		formatted = "." + raw.substr(raw.length() - 3, 3) + formatted
		raw = raw.substr(0, raw.length() - 3)
	return "Rp" + raw + formatted
