extends Control

var title_label: Label
var main_label: Label
var detail_label: Label
var next_button: Button
var beat_index: int = 0

var beats := [
	{
		"title": "KETUK. — DI BALIK HARGA",
		"main": "Kios belum buka penuh.",
		"detail": "Di laci kas: Rp430.000. Tunggakan kios: Rp1.200.000. Batas pembayaran: Minggu, 20:00."
	},
	{
		"title": "BUKU LAMA",
		"main": "Di bawah tumpukan nota ada buku keluarga yang jarang kamu buka.",
		"detail": "Di salah satu margin tertulis: “Kalau ragu, lihat bagian yang tidak dilihat orang.”"
	},
	{
		"title": "PAGI ITU",
		"main": "Selebaran Balai Lelang Kampung Suka Jaya terselip di antara koran.",
		"detail": "Lelang barang rumah tangga dan barang campuran dimulai siang ini. Kamu tidak punya cukup uang untuk banyak salah langkah."
	},
	{
		"title": "BALAI LELANG KAMPUNG SUKA JAYA",
		"main": "Kamu menutup buku, memasukkan uang ke dompet, lalu berangkat.",
		"detail": "Kamu menutup buku, mengambil dompet, lalu menuju balai."
	}
]

func _ready() -> void:
	AuctionState.start_chapter1()
	_build_ui()
	_show_beat()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#1c1714")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 60)
	margin.add_theme_constant_override("margin_bottom", 60)
	add_child(margin)

	var root := VBoxContainer.new()
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 24)
	margin.add_child(root)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 30)
	root.add_child(title_label)

	main_label = Label.new()
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_label.custom_minimum_size = Vector2(0, 180)
	main_label.add_theme_font_size_override("font_size", 27)
	root.add_child(main_label)

	detail_label = Label.new()
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.custom_minimum_size = Vector2(0, 220)
	detail_label.add_theme_font_size_override("font_size", 20)
	root.add_child(detail_label)

	next_button = Button.new()
	next_button.text = "LANJUT"
	next_button.custom_minimum_size = Vector2(240, 70)
	next_button.pressed.connect(_next)
	root.add_child(next_button)

func _show_beat() -> void:
	var beat: Dictionary = beats[beat_index]
	title_label.text = str(beat.get("title", ""))
	main_label.text = str(beat.get("main", ""))
	detail_label.text = str(beat.get("detail", ""))
	next_button.text = "KE BALAI LELANG" if beat_index == beats.size() - 1 else "LANJUT"

	if beat_index == 1:
		AuctionState.book_margin_line_seen = true

func _next() -> void:
	if beat_index < beats.size() - 1:
		beat_index += 1
		_show_beat()
		return

	get_tree().change_scene_to_file("res://scenes/auction/auction_room.tscn")
