extends Control

const LOT_DATA_PATH := "res://data/lots/prototype_lots.json"
const BidLogic = preload("res://scripts/auction/bid_logic.gd")

const DRAMA_CHAR_SECONDS := 0.012
const DRAMA_DIALOGUE_BASE := 1.6
const DRAMA_ACTION_BASE := 1.3
const DRAMA_SILENCE_BASE := 1.5
const DRAMA_PAUSE_SCALE := 1.55

var lots: Array = []
var lot_index: int = -1
var current_lot: Dictionary = {}
var awaiting_player: bool = false
var pak_slamet_prompted: bool = false
var wait_count: int = 0

var money_label: Label
var lot_label: Label
var description_label: Label
var bid_label: Label
var bidder_label: Label
var instruction_label: Label
var log_label: RichTextLabel

var jaka_label: Label
var ratna_label: Label
var slamet_label: Label

var action_row: HBoxContainer
var bid_button: Button
var wait_button: Button
var stop_button: Button

var investigate_panel: VBoxContainer
var investigation_text: Label
var continue_bid_button: Button
var inspect_button_1: Button
var inspect_button_2: Button
var inspect_button_3: Button
var inspected: Dictionary = {}

func _ready() -> void:
	_build_ui()
	_load_lots()
	AuctionState.reset_prototype()
	if lots.is_empty():
		_add_log("ERROR: data lot tidak ditemukan.")
		return
	_start_next_lot()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#211a17")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)

	var brand := Label.new()
	brand.text = "KETUK.  —  PROTOTYPE P0.3"
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand.add_theme_font_size_override("font_size", 26)
	root.add_child(brand)

	money_label = Label.new()
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	money_label.add_theme_font_size_override("font_size", 20)
	root.add_child(money_label)

	var divider := HSeparator.new()
	root.add_child(divider)

	lot_label = Label.new()
	lot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lot_label.add_theme_font_size_override("font_size", 28)
	lot_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(lot_label)

	description_label = Label.new()
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 18)
	root.add_child(description_label)

	var npc_row := HBoxContainer.new()
	npc_row.alignment = BoxContainer.ALIGNMENT_CENTER
	npc_row.add_theme_constant_override("separation", 18)
	root.add_child(npc_row)

	ratna_label = _make_npc_label("Bu Ratna", "NEUTRAL")
	npc_row.add_child(ratna_label)

	jaka_label = _make_npc_label("Jaka", "NEUTRAL")
	npc_row.add_child(jaka_label)

	slamet_label = _make_npc_label("Pak Slamet", "NEUTRAL")
	npc_row.add_child(slamet_label)

	var bid_panel := VBoxContainer.new()
	bid_panel.add_theme_constant_override("separation", 4)
	root.add_child(bid_panel)

	var current_caption := Label.new()
	current_caption.text = "TAWARAN SAAT INI"
	current_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_caption.add_theme_font_size_override("font_size", 16)
	bid_panel.add_child(current_caption)

	bid_label = Label.new()
	bid_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bid_label.add_theme_font_size_override("font_size", 42)
	bid_panel.add_child(bid_label)

	bidder_label = Label.new()
	bidder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bidder_label.add_theme_font_size_override("font_size", 17)
	bid_panel.add_child(bidder_label)

	instruction_label = Label.new()
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction_label.add_theme_font_size_override("font_size", 19)
	root.add_child(instruction_label)

	investigate_panel = VBoxContainer.new()
	investigate_panel.visible = false
	investigate_panel.add_theme_constant_override("separation", 10)
	root.add_child(investigate_panel)

	var investigation_title := Label.new()
	investigation_title.text = "INVESTIGATE — periksa sebelum menawar"
	investigation_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	investigation_title.add_theme_font_size_override("font_size", 19)
	investigate_panel.add_child(investigation_title)

	var hotspot_row := HBoxContainer.new()
	hotspot_row.alignment = BoxContainer.ALIGNMENT_CENTER
	hotspot_row.add_theme_constant_override("separation", 8)
	investigate_panel.add_child(hotspot_row)

	inspect_button_1 = Button.new()
	inspect_button_1.pressed.connect(func(): _inspect(0))
	hotspot_row.add_child(inspect_button_1)

	inspect_button_2 = Button.new()
	inspect_button_2.pressed.connect(func(): _inspect(1))
	hotspot_row.add_child(inspect_button_2)

	inspect_button_3 = Button.new()
	inspect_button_3.pressed.connect(func(): _inspect(2))
	hotspot_row.add_child(inspect_button_3)

	investigation_text = Label.new()
	investigation_text.text = "Pilih bagian yang ingin diperiksa, atau langsung mulai bidding."
	investigation_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	investigation_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	investigation_text.add_theme_font_size_override("font_size", 18)
	investigate_panel.add_child(investigation_text)

	continue_bid_button = Button.new()
	continue_bid_button.text = "MULAI BIDDING"
	continue_bid_button.disabled = false
	continue_bid_button.pressed.connect(_finish_investigation)
	investigate_panel.add_child(continue_bid_button)

	action_row = HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_CENTER
	action_row.add_theme_constant_override("separation", 10)
	root.add_child(action_row)

	bid_button = Button.new()
	bid_button.custom_minimum_size = Vector2(190, 72)
	bid_button.pressed.connect(_on_bid)
	action_row.add_child(bid_button)

	wait_button = Button.new()
	wait_button.text = "WAIT"
	wait_button.custom_minimum_size = Vector2(150, 72)
	wait_button.pressed.connect(_on_wait)
	action_row.add_child(wait_button)

	stop_button = Button.new()
	stop_button.text = "STOP"
	stop_button.custom_minimum_size = Vector2(150, 72)
	stop_button.pressed.connect(_on_stop)
	action_row.add_child(stop_button)

	log_label = RichTextLabel.new()
	log_label.bbcode_enabled = false
	log_label.fit_content = false
	log_label.custom_minimum_size = Vector2(0, 280)
	log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_label.add_theme_font_size_override("normal_font_size", 17)
	root.add_child(log_label)

func _make_npc_label(display_name: String, expression: String) -> Label:
	var label := Label.new()
	label.text = "%s\n[%s]" % [display_name, expression]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(180, 70)
	label.add_theme_font_size_override("font_size", 16)
	return label

func _load_lots() -> void:
	if not FileAccess.file_exists(LOT_DATA_PATH):
		push_error("Lot data not found: %s" % LOT_DATA_PATH)
		return

	var file := FileAccess.open(LOT_DATA_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_error("Lot data is invalid JSON.")
		return

	lots = parsed

func _start_next_lot() -> void:
	lot_index += 1
	if lot_index >= lots.size():
		_show_end_without_reveal()
		return

	current_lot = lots[lot_index]
	pak_slamet_prompted = false
	wait_count = 0
	inspected.clear()

	var lot_id := str(current_lot.get("id", ""))
	var opening_bid := int(current_lot.get("opening_bid", 0))
	AuctionState.set_lot(lot_id, opening_bid)

	lot_label.text = str(current_lot.get("title", "Lot"))
	description_label.text = str(current_lot.get("description", ""))
	_set_expression("bu_ratna", "NEUTRAL")
	_set_expression("jaka", "NEUTRAL")
	_set_expression("pak_slamet", "NEUTRAL")
	_refresh_state()
	_clear_log()
	_add_log("Barang diperlihatkan. Harga pembuka: %s." % _rupiah(opening_bid))
	_apply_session_memory_on_lot_start(lot_id)

	_show_investigation()

func _show_investigation() -> void:
	awaiting_player = false
	action_row.visible = false
	investigate_panel.visible = true
	instruction_label.text = "Sebelum menawar, kamu boleh memeriksa barang ini."
	investigation_text.text = "Pilih bagian yang ingin diperiksa, atau langsung mulai bidding."
	continue_bid_button.disabled = false
	_configure_investigation_buttons()

func _configure_investigation_buttons() -> void:
	var options: Array = current_lot.get("investigation", [])
	var buttons: Array[Button] = [inspect_button_1, inspect_button_2, inspect_button_3]

	for i in range(buttons.size()):
		var button := buttons[i]
		if i < options.size():
			var option: Dictionary = options[i]
			button.text = str(option.get("label", "PERIKSA"))
			button.visible = true
			button.disabled = false
		else:
			button.visible = false

func _inspect(index: int) -> void:
	var options: Array = current_lot.get("investigation", [])
	if index < 0 or index >= options.size():
		return

	var option: Dictionary = options[index]
	var option_id := str(option.get("id", "part_%d" % index))
	inspected[option_id] = true
	AuctionState.investigation[option_id] = true
	investigation_text.text = "%s — %s" % [
		str(option.get("label", "PERIKSA")),
		str(option.get("text", "Tidak ada catatan."))
	]

func _finish_investigation() -> void:
	investigate_panel.visible = false
	instruction_label.text = "Lelang dimulai."

	var opening_bid := int(current_lot.get("opening_bid", 0))
	_add_log("Pak Lurah: %s." % _rupiah(opening_bid))
	await get_tree().create_timer(0.65).timeout

	if AuctionState.current_lot_id == "lot03":
		AuctionState.record_bid("bu_ratna", 100000)
		_set_expression("bu_ratna", "INTERESTED")
		_add_log("Bu Ratna: %s." % _rupiah(100000))
		_refresh_state()
		await get_tree().create_timer(0.9).timeout

		AuctionState.record_bid("jaka", 120000)
		_set_expression("jaka", "NEUTRAL")
		_add_log("Jaka: %s." % _rupiah(120000))
		_refresh_state()
		await get_tree().create_timer(0.5).timeout

	_set_player_turn()

func _set_player_turn() -> void:
	awaiting_player = true
	action_row.visible = true
	_set_action_enabled(true)
	_refresh_state()
	instruction_label.text = "Giliranmu. Perhatikan barang dan orang di ruangan."

func _on_bid() -> void:
	if not awaiting_player:
		return

	var amount := _next_mc_bid()
	if amount <= AuctionState.current_bid:
		_add_log("Tidak ada langkah bid berikutnya di prototype ini.")
		return
	if amount > AuctionState.money:
		_add_log("Uangmu tidak cukup untuk bid itu.")
		return

	awaiting_player = false
	_set_action_enabled(false)
	AuctionState.record_bid("mc", amount)
	_add_log("Kamu: %s." % _rupiah(amount))
	_refresh_state()

	if AuctionState.current_lot_id == "lot03":
		var bid_count := AuctionState.mc_bid_history.size()
		if bid_count == 1:
			_set_expression("jaka", "INTERESTED")
			_add_log("Jaka tidak melihat kamera. Ia melihatmu.")
		elif bid_count == 2:
			_set_expression("jaka", "CONFIDENT")
		else:
			_set_expression("jaka", "SUSPICIOUS")

	await get_tree().create_timer(0.55).timeout
	await _npc_response_after_mc_bid(amount)

func _npc_response_after_mc_bid(mc_bid: int) -> void:
	match AuctionState.current_lot_id:
		"lot01":
			if mc_bid >= 125000 and not pak_slamet_prompted:
				pak_slamet_prompted = true
				_set_expression("pak_slamet", "INTERESTED")
				_add_log("Pak Slamet: \"Yang baru harganya berapa?\"")
				await get_tree().create_timer(0.8).timeout
			await _attempt_npc_bid("bu_ratna", mc_bid)
		"lot02":
			await _attempt_npc_bid("jaka", mc_bid)
		"lot03":
			await _attempt_npc_bid("jaka", mc_bid)

func _attempt_npc_bid(npc_id: String, mc_bid: int) -> void:
	var npc := NPCRegistry.get_npc(npc_id)
	var decision: Dictionary = BidLogic.decide_bid(
		npc_id,
		AuctionState.current_lot_id,
		AuctionState.current_bid,
		mc_bid,
		npc
	)

	if str(decision.get("action", "pass")) == "bid":
		var delay := float(npc.get("bid_speed", 0.8))
		await get_tree().create_timer(delay).timeout
		var amount := int(decision.get("amount", 0))
		AuctionState.record_bid(npc_id, amount)
		_add_log("%s: %s." % [NPCRegistry.get_display_name(npc_id), _rupiah(amount)])
		if npc_id == "jaka" and AuctionState.current_lot_id == "lot03":
			_set_expression("jaka", "CONFIDENT")
		_refresh_state()
		_set_player_turn()
		return

	if npc_id == "jaka" and AuctionState.current_lot_id == "lot03":
		_set_expression("jaka", "SURPRISED")
		_add_log("Jaka berhenti. Senyumnya hilang.")
		await get_tree().create_timer(0.7).timeout
		_set_expression("jaka", "NEUTRAL")
	elif npc_id == "bu_ratna":
		_add_log("Bu Ratna berhenti. Ia tidak mengejar harga lebih tinggi.")
	else:
		_add_log("%s berhenti menawar." % NPCRegistry.get_display_name(npc_id))

	await get_tree().create_timer(0.6).timeout
	await _finalize_lot()

func _on_wait() -> void:
	if not awaiting_player:
		return
	wait_count += 1
	_add_log("Kamu menunggu. Tidak ada penawar baru.")
	if AuctionState.current_lot_id == "lot03" and AuctionState.current_bidder == "jaka":
		if wait_count == 1:
			_set_expression("jaka", "CONFIDENT")
		else:
			_set_expression("jaka", "SUSPICIOUS")
	instruction_label.text = "WAIT tidak mengakhiri lot. Tekan STOP jika kamu benar-benar mundur."

func _on_stop() -> void:
	if not awaiting_player:
		return
	awaiting_player = false
	_set_action_enabled(false)

	if AuctionState.current_bidder == "auctioneer":
		_add_log("Kamu melewatkan lot ini.")
		AuctionState.record_result(AuctionState.current_lot_id, "none", 0)
		await get_tree().create_timer(0.6).timeout
		await _run_post_lot_drama("none")
		await get_tree().create_timer(0.7).timeout
		_start_next_lot()
		return

	if AuctionState.current_lot_id == "lot03" and AuctionState.current_bidder == "jaka":
		_set_expression("jaka", "SURPRISED")
		_add_log("Kamu STOP. Jaka baru sadar tawaran terakhir adalah miliknya.")
		await get_tree().create_timer(0.5).timeout

	await _finalize_lot()

func _finalize_lot() -> void:
	awaiting_player = false
	_set_action_enabled(false)

	var winner := AuctionState.current_bidder
	var amount := AuctionState.current_bid

	_add_log("Pak Lurah: \"%s, satu kali... dua kali... TERJUAL.\"" % _rupiah(amount))
	await get_tree().create_timer(0.85).timeout

	AuctionState.record_result(AuctionState.current_lot_id, winner, amount)
	_refresh_state()

	await get_tree().create_timer(1.0).timeout
	await _run_post_lot_drama(winner)

	if AuctionState.current_lot_id == "lot03":
		await get_tree().create_timer(1.25).timeout
		get_tree().change_scene_to_file("res://scenes/reveal/reveal_camera.tscn")
		return

	await get_tree().create_timer(1.2).timeout
	_start_next_lot()

func _run_post_lot_drama(winner: String) -> void:
	var drama_map: Dictionary = current_lot.get("post_lot_drama", {})
	var beats: Array = drama_map.get(winner, [])

	if beats.is_empty():
		return

	_add_log("—")
	instruction_label.text = "Lot selesai. Ruangan belum benar-benar diam."

	for beat_value in beats:
		if typeof(beat_value) != TYPE_DICTIONARY:
			continue

		var beat: Dictionary = beat_value
		var actor := str(beat.get("actor", "room"))
		var kind := str(beat.get("kind", "dialogue"))
		var expression := str(beat.get("expression", ""))
		var line := str(beat.get("text", ""))
		var delay_before := float(beat.get("delay_before", 0.0))
		var pause := float(beat.get("pause", 0.8))

		if delay_before > 0.0:
			await get_tree().create_timer(delay_before).timeout

		if not expression.is_empty():
			match actor:
				"jaka":
					_set_expression("jaka", expression)
				"bu_ratna":
					_set_expression("bu_ratna", expression)
				"pak_slamet":
					_set_expression("pak_slamet", expression)

		if kind == "silence":
			if not line.is_empty():
				instruction_label.text = line
			await get_tree().create_timer(_drama_hold_time(kind, line, pause)).timeout
			continue

		if not line.is_empty():
			instruction_label.text = line
			_add_log(_format_drama_line(kind, line))

		await get_tree().create_timer(_drama_hold_time(kind, line, pause)).timeout

	instruction_label.text = "Pak Lurah bersiap ke lot berikutnya."

func _drama_hold_time(kind: String, line: String, authored_pause: float) -> float:
	var base := DRAMA_DIALOGUE_BASE
	match kind:
		"silence":
			base = DRAMA_SILENCE_BASE
		"action", "crowd":
			base = DRAMA_ACTION_BASE
		"interrupt":
			base = DRAMA_DIALOGUE_BASE

	var reading_time := base + (float(line.length()) * DRAMA_CHAR_SECONDS)
	var authored_time := authored_pause * DRAMA_PAUSE_SCALE
	return maxf(reading_time, authored_time)

func _apply_session_memory_on_lot_start(lot_id: String) -> void:
	if lot_id != "lot03":
		return

	var attitude := str(AuctionState.session_memory.get("jaka_attitude", "neutral"))
	match attitude:
		"stung":
			_set_expression("jaka", "SUSPICIOUS")
			_add_log("Jaka sempat melirik ke arahmu saat kamera dibawa masuk.")
		"cocky":
			_set_expression("jaka", "CONFIDENT")
			_add_log("Jaka bersandar santai ketika kamera dibawa masuk.")
		_:
			pass

func _format_drama_line(kind: String, line: String) -> String:
	match kind:
		"action":
			return "• " + line
		"crowd":
			return "RUANGAN — " + line
		"interrupt":
			return "↳ " + line
		_:
			return line

func _next_mc_bid() -> int:
	var steps: Array = current_lot.get("mc_bid_steps", [])
	for value in steps:
		var amount := int(value)
		if amount > AuctionState.current_bid:
			return amount
	return AuctionState.current_bid + 10000

func _refresh_state() -> void:
	money_label.text = "Uang: %s" % _rupiah(AuctionState.money)
	bid_label.text = _rupiah(AuctionState.current_bid)
	bidder_label.text = "Tertinggi: %s" % _bidder_name(AuctionState.current_bidder)

	var next_bid := _next_mc_bid()
	bid_button.text = "BID\n%s" % _rupiah(next_bid)

func _set_expression(npc_id: String, expression: String) -> void:
	match npc_id:
		"jaka":
			jaka_label.text = "Jaka\n[%s]" % expression
		"bu_ratna":
			ratna_label.text = "Bu Ratna\n[%s]" % expression
		"pak_slamet":
			slamet_label.text = "Pak Slamet\n[%s]" % expression

func _set_action_enabled(enabled: bool) -> void:
	bid_button.disabled = not enabled
	wait_button.disabled = not enabled
	stop_button.disabled = not enabled

func _bidder_name(id: String) -> String:
	match id:
		"mc":
			return "Kamu"
		"bu_ratna":
			return "Bu Ratna"
		"jaka":
			return "Jaka"
		"auctioneer":
			return "Harga pembuka"
		"none":
			return "Tidak ada"
		_:
			return id

func _clear_log() -> void:
	log_label.text = ""

func _add_log(line: String) -> void:
	if log_label.text.is_empty():
		log_label.text = line
	else:
		log_label.text += "\n" + line

func _rupiah(value: int) -> String:
	var raw := str(value)
	var formatted := ""
	while raw.length() > 3:
		formatted = "." + raw.substr(raw.length() - 3, 3) + formatted
		raw = raw.substr(0, raw.length() - 3)
	return "Rp" + raw + formatted

func _show_end_without_reveal() -> void:
	lot_label.text = "Sesi lelang selesai"
	description_label.text = "Tidak ada tindak lanjut untuk sesi ini."
	instruction_label.text = "Restart project untuk mencoba lagi."
	action_row.visible = false
