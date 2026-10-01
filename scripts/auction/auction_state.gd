extends Node

var money: int = 430000
var current_lot_id: String = ""
var current_bid: int = 0
var current_bidder: String = ""
var mc_bid_history: Array[int] = []
var bid_history: Array[Dictionary] = []
var lot_results: Dictionary = {}
var investigation: Dictionary = {}
var session_memory: Dictionary = {}
var discovery_notes: Dictionary = {}
var discovery_target: String = ""
var inventory: Dictionary = {}
var selected_inventory_item: String = ""
var world_flags: Dictionary = {}
var network_history: Array[Dictionary] = []
var network_finding: String = ""
var network_known_contacts: Dictionary = {}
var network_visited_locations: Dictionary = {}
var network_travel_steps: int = 0

var chapter_mode: bool = false
var chapter_id: String = ""
var chapter1_started: bool = false
var chapter1_complete: bool = false
var kiosk_arrears: int = 1200000
var kiosk_deadline: String = "Minggu 20:00"
var book_margin_line_seen: bool = false
var camera_appraisal_seen: bool = false

var chapter2_started: bool = false
var chapter2_complete: bool = false
var chapter2_route: String = ""
var chapter2_time_minutes: int = 16 * 60
var kiosk_saved: bool = false
var kiosk_paid: int = 0
var camera_sale_status: String = ""
var chapter2_known_places: Dictionary = {}
var chapter2_leads: Dictionary = {}
var chapter2_visited: Dictionary = {}
var chapter2_extension_granted: bool = false
var chapter2_deadline_minutes: int = 20 * 60
var chapter2_pending_offer: int = 0

var chapter3_started: bool = false
var chapter3_complete: bool = false
var chapter3_people_book: Dictionary = {}
var chapter3_context_found: bool = false
var chapter3_poster_seen: bool = false
var chapter3_poster_photographed: bool = false

func reset_prototype() -> void:
	money = 430000
	current_lot_id = ""
	current_bid = 0
	current_bidder = ""
	mc_bid_history.clear()
	bid_history.clear()
	lot_results.clear()
	investigation.clear()
	session_memory.clear()
	discovery_notes.clear()
	discovery_target = ""
	inventory.clear()
	selected_inventory_item = ""
	world_flags.clear()
	network_history.clear()
	network_finding = ""
	network_known_contacts.clear()
	network_visited_locations.clear()
	network_travel_steps = 0
	chapter_mode = false
	chapter_id = ""
	chapter1_started = false
	chapter1_complete = false
	book_margin_line_seen = false
	camera_appraisal_seen = false
	chapter2_started = false
	chapter2_complete = false
	chapter2_route = ""
	chapter2_time_minutes = 16 * 60
	kiosk_saved = false
	kiosk_paid = 0
	camera_sale_status = ""
	chapter2_known_places.clear()
	chapter2_leads.clear()
	chapter2_visited.clear()
	chapter2_extension_granted = false
	chapter2_deadline_minutes = 20 * 60
	chapter2_pending_offer = 0
	chapter3_started = false
	chapter3_complete = false
	chapter3_people_book.clear()
	chapter3_context_found = false
	chapter3_poster_seen = false
	chapter3_poster_photographed = false

func set_lot(lot_id: String, opening_bid: int) -> void:
	current_lot_id = lot_id
	current_bid = opening_bid
	current_bidder = "auctioneer"
	mc_bid_history.clear()
	bid_history.clear()
	investigation.clear()

func record_bid(bidder: String, amount: int) -> void:
	current_bid = amount
	current_bidder = bidder
	bid_history.append({
		"bidder": bidder,
		"amount": amount
	})
	if bidder == "mc":
		mc_bid_history.append(amount)

func record_result(lot_id: String, winner: String, amount: int) -> void:
	lot_results[lot_id] = {
		"winner": winner,
		"amount": amount
	}
	if winner == "mc":
		money -= amount
		if lot_id == "lot02":
			add_inventory_item("mixed_box", {
				"name": "KOTAK CAMPURAN",
				"state": "closed",
				"description": "Kotak dari lot campuran. Ada beberapa benda di dalamnya. Penutupnya keras dan tidak terbuka dengan tangan.",
				"source": "Lot 02"
			})
		elif lot_id == "lot03":
			add_inventory_item("camera", {
				"name": "KAMERA ANALOG",
				"state": "owned",
				"description": "Kamera analog bekas. Body dan lensanya tampak seperti pasangan yang perlu diperiksa lebih jauh.",
				"source": "Lot 03"
			})

	if lot_id == "lot02":
		session_memory["lot02_winner"] = winner
		if winner == "mc":
			session_memory["jaka_attitude"] = "stung"
		elif winner == "jaka":
			session_memory["jaka_attitude"] = "cocky"
		else:
			session_memory["jaka_attitude"] = "neutral"


func start_chapter1() -> void:
	reset_prototype()
	chapter_mode = true
	chapter_id = "chapter1"
	chapter1_started = true
	kiosk_arrears = 1200000
	kiosk_deadline = "Minggu 20:00"
	money = 430000

func finish_chapter1() -> void:
	chapter1_complete = true


func start_chapter2() -> void:
	chapter_mode = true
	chapter_id = "chapter2"
	chapter2_started = true
	chapter2_complete = false
	chapter2_route = ""
	chapter2_time_minutes = 16 * 60
	kiosk_saved = false
	kiosk_paid = 0
	camera_sale_status = ""
	chapter2_known_places = {
		"rumah": true,
		"toko_kamera": true,
		"warung_ratna": true,
		"pak_arman": true
	}
	chapter2_leads.clear()
	chapter2_visited.clear()
	chapter2_extension_granted = false
	chapter2_deadline_minutes = 20 * 60
	chapter2_pending_offer = 0

func advance_chapter2_time(minutes: int) -> void:
	chapter2_time_minutes += minutes

func chapter2_clock() -> String:
	var day_minutes := chapter2_time_minutes % (24 * 60)
	var hour := int(day_minutes / 60)
	var minute := int(day_minutes % 60)
	return "%02d:%02d" % [hour, minute]

func chapter2_day_name() -> String:
	return "Senin" if chapter2_time_minutes >= 24 * 60 else "Minggu"

func chapter2_deadline_label() -> String:
	if chapter2_extension_granted:
		return "Senin 10:00"
	return "Minggu 20:00"

func chapter2_deadline_absolute_minutes() -> int:
	if chapter2_extension_granted:
		return 24 * 60 + 10 * 60
	return 20 * 60

func chapter2_past_deadline() -> bool:
	return chapter2_time_minutes > chapter2_deadline_absolute_minutes()

func pay_kiosk(amount: int) -> void:
	kiosk_paid += amount
	money -= amount
	if kiosk_paid >= kiosk_arrears:
		kiosk_saved = true

func finish_chapter2(route_id: String) -> void:
	chapter2_route = route_id
	chapter2_complete = true


func start_chapter3() -> void:
	chapter_mode = true
	chapter_id = "chapter3"
	chapter3_started = true
	chapter3_complete = false
	chapter3_people_book.clear()
	chapter3_context_found = false
	chapter3_poster_seen = false
	chapter3_poster_photographed = false
	network_history.clear()
	network_finding = ""
	network_known_contacts.clear()
	network_visited_locations.clear()
	network_travel_steps = 0

func record_chapter3_person(person_id: String, note: String) -> void:
	chapter3_people_book[person_id] = note

func finish_chapter3() -> void:
	chapter3_complete = true


func add_inventory_item(item_id: String, item_data: Dictionary) -> void:
	inventory[item_id] = item_data.duplicate(true)

func remove_inventory_item(item_id: String) -> void:
	inventory.erase(item_id)
	if selected_inventory_item == item_id:
		selected_inventory_item = ""

func has_inventory_item(item_id: String) -> bool:
	return inventory.has(item_id)

func get_inventory_item(item_id: String) -> Dictionary:
	return inventory.get(item_id, {})

func update_inventory_item(item_id: String, changes: Dictionary) -> void:
	if not inventory.has(item_id):
		return
	var item: Dictionary = inventory[item_id]
	for key in changes.keys():
		item[key] = changes[key]
	inventory[item_id] = item

func inventory_item_name(item_id: String) -> String:
	var item: Dictionary = inventory.get(item_id, {})
	return str(item.get("name", item_id.to_upper()))

func open_mixed_box() -> void:
	if not inventory.has("mixed_box"):
		return
	var box: Dictionary = inventory["mixed_box"]
	if str(box.get("state", "")) == "opened":
		return

	box["state"] = "opened"
	box["description"] = "Kotaknya sudah dibuka. Isi yang berguna dipisahkan."
	inventory["mixed_box"] = box

	add_inventory_item("coaster", {
		"name": "TATAKAN LOGAM",
		"state": "unknown",
		"description": "Permukaan kuning kusam. Tepi menunjukkan warna berbeda.",
		"source": "Kotak Campuran"
	})
	add_inventory_item("lighter", {
		"name": "KOREK MEJA",
		"state": "unknown",
		"description": "Korek meja lama. Mekanismenya seret dan ada cap kecil yang aus.",
		"source": "Kotak Campuran"
	})
	add_inventory_item("adapter", {
		"name": "ADAPTOR LAMA",
		"state": "unknown",
		"description": "Adaptor dengan konektor model lama. Kabel tampak pernah diganti.",
		"source": "Kotak Campuran"
	})
	world_flags["mixed_box_opened"] = true
