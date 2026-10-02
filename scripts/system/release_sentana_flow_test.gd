extends Node

const WORLD_SCENE = preload("res://scenes/chapter/chapter2_batas.tscn")

func _ready() -> void:
	var failures: Array[String] = []

	AuctionState.start_chapter1()
	AuctionState.finish_chapter1()
	AuctionState.start_chapter2()
	AuctionState.chapter2_time_minutes = 24 * 60 + 9 * 60

	AuctionState.start_chapter3()
	AuctionState.chapter3_poster_seen = true
	AuctionState.chapter3_poster_photographed = true
	AuctionState.add_inventory_item("sentana_photo", {
		"name": "FOTO POSTER SENTANA",
		"state": "photo",
		"description": "Foto poster bertuliskan SENTANA PRIVATE AUCTION — BY INVITATION ONLY.",
		"source": "Papan Pengumuman Pasar Tua"
	})

	_expect(
		AuctionState.start_sentana_access(),
		"poster_starts_access_investigation",
		failures
	)

	var world = WORLD_SCENE.instantiate()
	add_child(world)
	await get_tree().process_frame

	world.call("_show_item_to_terminal", "sentana_photo")
	_expect(
		AuctionState.sentana_invitation_leads.has("terminal_poster"),
		"terminal_recognizes_poster",
		failures
	)

	world.call("_ask_terminal")
	_expect(
		AuctionState.chapter2_known_places.has("alamat_sentana"),
		"terminal_unlocks_address",
		failures
	)
	_expect(
		AuctionState.sentana_invitation_leads.has("terminal_address"),
		"terminal_connects_address_to_invitation_route",
		failures
	)

	AuctionState.selected_inventory_item = "sentana_photo"
	world.set("current_location_id", "alamat_sentana")
	world.call("_present_sentana_photo_at_address")

	_expect(
		AuctionState.has_sentana_invitation(),
		"address_grants_invitation",
		failures
	)
	_expect(
		AuctionState.sentana_access_status == "invited",
		"access_status_invited",
		failures
	)
	_expect(
		AuctionState.sentana_invitation_source == "Meja depan — alamat kota",
		"invitation_source",
		failures
	)

	var inventory_count := AuctionState.inventory.size()
	world._present_sentana_photo_at_address()
	_expect(
		AuctionState.inventory.size() == inventory_count,
		"no_duplicate_invitation_item",
		failures
	)

	world.call("_clear_actions")
	world.call("_build_sentana_actions")
	var action_labels: Array[String] = []
	var action_row := world.get("action_row") as VBoxContainer
	_expect(action_row != null, "action_row_available", failures)
	if action_row == null:
		_finish(failures)
		return

	for child in action_row.get_children():
		if child is Button:
			action_labels.append(child.text)

	_expect(
		action_labels.has("PERIKSA UNDANGAN"),
		"post_invite_action_available",
		failures
	)
	_expect(
		not action_labels.has("TUNJUKKAN FOTO POSTER"),
		"post_invite_grant_action_removed",
		failures
	)

	_finish(failures)

func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("SENTANA_FLOW_OK")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error("SENTANA_FLOW_FAIL=" + failure)
	get_tree().quit(1)

func _expect(condition: bool, label: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(label)
