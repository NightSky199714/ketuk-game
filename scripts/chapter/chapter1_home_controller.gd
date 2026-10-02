extends Control

const ICON_BOOK = preload("res://assets/ui/icons/book.svg")
const ICON_CAMERA = preload("res://assets/ui/icons/camera.svg")
const ICON_BOX = preload("res://assets/ui/icons/box.svg")

@onready var title_label: Label = $Margin/Scroll/Root/HeaderPanel/HeaderMargin/HeaderStack/TitleLabel
@onready var main_label: Label = $Margin/Scroll/Root/NarrativePanel/NarrativeMargin/MainLabel
@onready var detail_label: Label = $Margin/Scroll/Root/HeaderPanel/HeaderMargin/HeaderStack/DetailLabel
@onready var inventory_grid: GridContainer = $Margin/Scroll/Root/InventoryPanel/InventoryMargin/InventoryStack/InventoryGrid
@onready var item_detail_label: Label = $Margin/Scroll/Root/InventoryPanel/InventoryMargin/InventoryStack/ItemDetailFrame/ItemDetailMargin/ItemDetailScroll/ItemDetailLabel
@onready var next_button: Button = $Margin/Scroll/Root/NextButton

func _ready() -> void:
	AuctionState.finish_chapter1()
	next_button.pressed.connect(_leave_home)
	_refresh_home()
	SaveManager.save_game("res://scenes/chapter/chapter1_home.tscn")

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
		button.icon = _inventory_icon(str(item_id))
		button.add_theme_constant_override("icon_max_width", 26)
		button.expand_icon = true
		button.theme_type_variation = &"SelectedButton" if AuctionState.selected_inventory_item == str(item_id) else &""
		var captured_id := str(item_id)
		button.pressed.connect(func(): _select_item(captured_id))
		inventory_grid.add_child(button)

	if AuctionState.selected_inventory_item.is_empty():
		item_detail_label.text = "Belum ada barang yang dipilih."
	else:
		_show_selected_item()

func _inventory_icon(item_id: String) -> Texture2D:
	match item_id:
		"book":
			return ICON_BOOK
		"camera":
			return ICON_CAMERA
		_:
			return ICON_BOX

func _select_item(item_id: String) -> void:
	AuctionState.selected_inventory_item = item_id
	_refresh_inventory()

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
