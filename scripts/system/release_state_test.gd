extends Node

func _ready() -> void:
	var failures: Array[String] = []

	AuctionState.start_chapter1()
	AuctionState.record_result("lot02", "mc", 95000)
	AuctionState.record_result("lot03", "mc", 260000)
	AuctionState.finish_chapter1()
	AuctionState.start_chapter2()

	AuctionState.chapter2_time_minutes = 18 * 60 + 35
	AuctionState.kiosk_paid = 400000
	AuctionState.world_flags["world_location"] = "pasar_tua"
	AuctionState.world_flags["custom_test_flag"] = "kept"
	AuctionState.chapter2_leads["sentana"] = true
	AuctionState.chapter2_known_places["alamat_sentana"] = true
	AuctionState.chapter2_visited["terminal_kota"] = true
	AuctionState.chapter2_extension_granted = true

	var money_before_adi := AuctionState.money
	var first_adi_sale := AuctionState.sell_camera_lens_to_adi()
	var money_after_first_adi := AuctionState.money
	var second_adi_sale := AuctionState.sell_camera_lens_to_adi()

	_expect(first_adi_sale, "adi_first_sale_succeeds", failures)
	_expect(not second_adi_sale, "adi_second_sale_rejected", failures)
	_expect(
		money_after_first_adi == money_before_adi + 2100000,
		"adi_first_sale_payout",
		failures
	)
	_expect(
		AuctionState.money == money_after_first_adi,
		"adi_no_duplicate_payout",
		failures
	)
	_expect(
		not AuctionState.camera_lens_available(),
		"adi_lens_consumed_after_sale",
		failures
	)

	AuctionState.open_mixed_box()
	AuctionState.hear_rumor(
		"sentana_name",
		"Katanya ada nama Sentana yang beredar.",
		"Release Test"
	)
	AuctionState.remember_npc_event("pak_wira", "shown_lighter")
	AuctionState.start_chapter3()
	AuctionState.record_chapter3_person(
		"pak_wira",
		"Pak Wira — pedagang tua di Kios Tengah."
	)
	AuctionState.chapter3_poster_seen = true

	var before := AuctionState.export_save_data()
	AuctionState.reset_prototype()
	AuctionState.import_save_data(before)

	_expect(AuctionState.money == 2175000, "money", failures)
	_expect(AuctionState.chapter1_complete, "chapter1_complete", failures)
	_expect(AuctionState.chapter2_started, "chapter2_started", failures)
	_expect(AuctionState.chapter2_time_minutes == 18 * 60 + 35, "world_time", failures)
	_expect(AuctionState.kiosk_paid == 400000, "kiosk_paid", failures)
	_expect(
		str(AuctionState.world_flags.get("world_location", "")) == "pasar_tua",
		"world_location",
		failures
	)
	_expect(
		str(AuctionState.world_flags.get("custom_test_flag", "")) == "kept",
		"world_flags",
		failures
	)
	_expect(AuctionState.chapter2_extension_granted, "deadline_extension", failures)
	_expect(AuctionState.has_inventory_item("book"), "book_inventory", failures)
	_expect(AuctionState.has_inventory_item("mixed_box"), "mixed_box_inventory", failures)
	_expect(AuctionState.has_inventory_item("camera"), "camera_inventory", failures)
	_expect(
		str(AuctionState.get_inventory_item("camera").get("state", "")) == "body_only",
		"camera_body_only_after_adi",
		failures
	)
	_expect(
		AuctionState.camera_sale_status == "lens_only_2100_body_returned",
		"camera_sale_status_persisted",
		failures
	)
	var money_before_repeat_after_load := AuctionState.money
	_expect(
		not AuctionState.sell_camera_lens_to_adi(),
		"adi_sale_still_rejected_after_load",
		failures
	)
	_expect(
		AuctionState.money == money_before_repeat_after_load,
		"adi_no_duplicate_payout_after_load",
		failures
	)
	_expect(AuctionState.has_inventory_item("coaster"), "coaster_inventory", failures)
	_expect(AuctionState.has_inventory_item("lighter"), "lighter_inventory", failures)
	_expect(AuctionState.has_inventory_item("adapter"), "adapter_inventory", failures)
	_expect(AuctionState.rumor_status("sentana_name") == "heard", "rumor_status", failures)
	_expect(AuctionState.npc_remembers("pak_wira", "shown_lighter"), "npc_memory", failures)
	_expect(
		AuctionState.chapter3_people_book.has("pak_wira"),
		"people_book",
		failures
	)
	_expect(AuctionState.chapter3_poster_seen, "poster_seen", failures)

	if failures.is_empty():
		print("STATE_ROUNDTRIP_OK")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error("STATE_ROUNDTRIP_FAIL=" + failure)
	get_tree().quit(1)

func _expect(condition: bool, label: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(label)
