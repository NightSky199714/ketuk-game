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
