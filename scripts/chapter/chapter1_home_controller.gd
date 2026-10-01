extends Control

var title_label: Label
var main_label: Label
var detail_label: Label
var inventory_grid: GridContainer
var item_detail_label: Label
var next_button: Button

func _ready() -> void:
	AuctionState.finish_chapter1()
	_build_ui()
	_refresh_home()
	SaveManager.save_game("res://scenes/chapter/chapter1_home.tscn")

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
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 18)
	margin.add_child(root)

	title_label = Label.new()
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 29)
	root.add_child(title_label)

	main_label = Label.new()
	main_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_label.custom_minimum_size = Vector2(0, 120)
	main_label.add_theme_font_size_override("font_size", 22)
	root.add_child(main_label)

	detail_label = Label.new()
	detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.custom_minimum_size = Vector2(0, 100)
	detail_label.add_theme_font_size_override("font_size", 18)
	root.add_child(detail_label)

	var inv_title := Label.new()
	inv_title.text = "INVENTORY"
	inv_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inv_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inv_title.add_theme_font_size_override("font_size", 19)
	root.add_child(inv_title)

	inventory_grid = GridContainer.new()
	inventory_grid.columns = 2
	inventory_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_grid.add_theme_constant_override("h_separation", 8)
	inventory_grid.add_theme_constant_override("v_separation", 8)
	root.add_child(inventory_grid)

	item_detail_label = Label.new()
	item_detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_detail_label.custom_minimum_size = Vector2(0, 170)
	item_detail_label.add_theme_font_size_override("font_size", 18)
	root.add_child(item_detail_label)

	next_button = Button.new()
	next_button.text = "KELUAR RUMAH"
	next_button.custom_minimum_size = Vector2(260, 68)
	next_button.pressed.connect(_leave_home)
	root.add_child(next_button)

func _refresh_home() -> void:
	title_label.text = "MALAM — RUMAH"
	main_label.text = "Kamu menaruh barang hasil lelang di meja. Tidak semuanya langsung memberi jawaban."
	detail_label.text = "Uang tersisa: %s" % _rupiah(AuctionState.money)
	_refresh_inventory()

func _refresh_inventory() -> void:
	for child in inventory_grid.get_children():
		child.queue_free()

	if AuctionState.inventory.is_empty():
		item_detail_label.text = "Tidak ada barang hasil lelang yang kamu bawa pulang."
		return

	for item_id in AuctionState.inventory.keys():
		var item: Dictionary = AuctionState.get_inventory_item(str(item_id))
		var button := Button.new()
		button.text = str(item.get("name", str(item_id).to_upper()))
		button.custom_minimum_size = Vector2(0, 62)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var captured_id := str(item_id)
		button.pressed.connect(func(): _select_item(captured_id))
		inventory_grid.add_child(button)

	if AuctionState.selected_inventory_item.is_empty():
		item_detail_label.text = "Belum ada barang yang dipilih."
	else:
		_show_selected_item()

func _select_item(item_id: String) -> void:
	AuctionState.selected_inventory_item = item_id
	_show_selected_item()

func _show_selected_item() -> void:
	var item_id := AuctionState.selected_inventory_item
	var item: Dictionary = AuctionState.get_inventory_item(item_id)
	if item.is_empty():
		item_detail_label.text = ""
		return

	if item_id == "book":
		item_detail_label.text = "BUKU LAMA\n\n%s" % AuctionState.book_text()
		return

	var text := "%s\n%s" % [
		str(item.get("name", item_id.to_upper())),
		str(item.get("description", "Belum ada catatan."))
	]

	if item_id == "camera" and AuctionState.camera_appraisal_seen:
		text += "\n\nPak Harun pernah menaruh perhatian lebih pada lensanya daripada bodynya."

	if item_id == "mixed_box" and str(item.get("state", "")) == "closed":
		text += "\n\nPenutupnya tidak bergerak saat dicoba dengan tangan."

	item_detail_label.text = text

func _leave_home() -> void:
	get_tree().change_scene_to_file("res://scenes/chapter/chapter2_batas.tscn")

func _rupiah(value: int) -> String:
	var raw := str(value)
	var formatted := ""
	while raw.length() > 3:
		formatted = "." + raw.substr(raw.length() - 3, 3) + formatted
		raw = raw.substr(0, raw.length() - 3)
	return "Rp" + raw + formatted
