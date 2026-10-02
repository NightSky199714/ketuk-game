extends Control

@onready var title_label: Label = $Margin/Scroll/Root/HeaderPanel/HeaderMargin/HeaderStack/TitleLabel
@onready var ownership_label: Label = $Margin/Scroll/Root/HeaderPanel/HeaderMargin/HeaderStack/OwnershipLabel
@onready var main_label: Label = $Margin/Scroll/Root/NarrativePanel/NarrativeMargin/NarrativeStack/MainLabel
@onready var detail_label: Label = $Margin/Scroll/Root/NarrativePanel/NarrativeMargin/NarrativeStack/DetailLabel
@onready var jaka_label: Label = $Margin/Scroll/Root/NpcRow/JakaCard/JakaLabel
@onready var ratna_label: Label = $Margin/Scroll/Root/NpcRow/RatnaCard/RatnaLabel
@onready var slamet_label: Label = $Margin/Scroll/Root/NpcRow/SlametCard/SlametLabel
@onready var choice_panel: HBoxContainer = $Margin/Scroll/Root/ChoicePanel
@onready var followup_button: Button = $Margin/Scroll/Root/ChoicePanel/FollowupButton
@onready var leave_button: Button = $Margin/Scroll/Root/ChoicePanel/LeaveButton
@onready var end_panel: VBoxContainer = $Margin/Scroll/Root/EndPanel
@onready var end_title: Label = $Margin/Scroll/Root/EndPanel/EndTitlePanel/EndTitle
@onready var discovery_button: Button = $Margin/Scroll/Root/EndPanel/DiscoveryButton
@onready var restart_button: Button = $Margin/Scroll/Root/EndPanel/RestartButton

var winner: String = "none"

func _ready() -> void:
	var result: Dictionary = AuctionState.lot_results.get("lot03", {})
	winner = str(result.get("winner", "none"))

	if winner == "mc":
		ownership_label.text = "Kamera ada di tanganmu."
	elif winner == "jaka":
		ownership_label.text = "Kamera ada di tangan Jaka."
	else:
		ownership_label.text = "Kamera tidak berpindah ke tanganmu."

	end_title.text = "SESUDAH LELANG" if AuctionState.chapter_mode else "P0.1 — AUCTION FEEL SELESAI"
	discovery_button.text = "PULANG" if AuctionState.chapter_mode else "LANJUT KE TEMUAN"
	discovery_button.visible = true if AuctionState.chapter_mode else _owns_lot02()

	followup_button.pressed.connect(_on_followup)
	leave_button.pressed.connect(_on_leave)
	discovery_button.pressed.connect(_continue_after_auction)
	restart_button.pressed.connect(_restart)

	await get_tree().create_timer(0.45).timeout
	_show_post_auction_context()

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
