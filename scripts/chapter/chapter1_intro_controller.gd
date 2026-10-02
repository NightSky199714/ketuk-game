extends Control

@onready var title_label: Label = $Margin/Root/TitlePanel/TitleMargin/TitleLabel
@onready var main_label: Label = $Margin/Root/MainPanel/MainMargin/MainLabel
@onready var detail_label: Label = $Margin/Root/DetailPanel/DetailMargin/DetailLabel
@onready var step_label: Label = $Margin/Root/StepLabel
@onready var next_button: Button = $Margin/Root/NextButton
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
	next_button.pressed.connect(_next)
	_show_beat()

func _show_beat() -> void:
	var beat: Dictionary = beats[beat_index]
	title_label.text = str(beat.get("title", ""))
	main_label.text = str(beat.get("main", ""))
	detail_label.text = str(beat.get("detail", ""))
	step_label.text = "%d / %d" % [beat_index + 1, beats.size()]
	next_button.text = "KE BALAI LELANG" if beat_index == beats.size() - 1 else "LANJUT"

	if beat_index == 1:
		AuctionState.book_margin_line_seen = true

func _next() -> void:
	if beat_index < beats.size() - 1:
		beat_index += 1
		_show_beat()
		return

	get_tree().change_scene_to_file("res://scenes/auction/auction_room.tscn")
