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
	AuctionState.chapter3_poster_photographed = true
	AuctionState.add_inventory_item("sentana_photo", {
		"name": "FOTO POSTER SENTANA",
		"state": "photo",
		"description": "Foto poster bertuliskan SENTANA PRIVATE AUCTION — BY INVITATION ONLY.",
		"source": "Papan Pengumuman Pasar Tua"
	})

	_expect(
		AuctionState.start_sentana_access(),
		"sentana_access_starts_with_poster",
		failures
	)
	_expect(
		AuctionState.record_sentana_invitation_lead(
			"lead_release_test",
			"Seseorang mengenali poster dan menyebut jalur undangan."
		),
		"sentana_first_lead_recorded",
		failures
	)
	_expect(
		not AuctionState.record_sentana_invitation_lead(
			"lead_release_test",
			"Duplikat tidak boleh mengganti lead pertama."
		),
		"sentana_duplicate_lead_rejected",
		failures
	)
	_expect(
		AuctionState.grant_sentana_invitation("Release Test"),
		"sentana_first_invitation_granted",
		failures
	)
	_expect(
		not AuctionState.grant_sentana_invitation("Duplicate Release Test"),
		"sentana_duplicate_invitation_rejected",
		failures
	)

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
	_expect(AuctionState.chapter3_poster_photographed, "poster_photo_persisted", failures)
	_expect(AuctionState.has_inventory_item("sentana_photo"), "sentana_photo_inventory", failures)
	_expect(AuctionState.sentana_access_started, "sentana_access_started", failures)
	_expect(
		AuctionState.sentana_access_status == "invited",
		"sentana_access_status",
		failures
	)
	_expect(
		AuctionState.sentana_invitation_leads.has("lead_release_test"),
		"sentana_lead_persisted",
		failures
	)
	_expect(
		AuctionState.sentana_invitation_source == "Release Test",
		"sentana_invitation_source",
		failures
	)
	_expect(AuctionState.has_sentana_invitation(), "sentana_invitation_inventory", failures)

	var invitation_count_before_repeat := AuctionState.inventory.size()
	_expect(
		not AuctionState.grant_sentana_invitation("After Load Duplicate"),
		"sentana_duplicate_invitation_rejected_after_load",
		failures
	)
	_expect(
		AuctionState.inventory.size() == invitation_count_before_repeat,
		"sentana_no_duplicate_inventory_after_load",
		failures
	)

	var people_before_restart := AuctionState.chapter3_people_book.duplicate(true)
	var poster_before_restart := AuctionState.chapter3_poster_seen
	var network_steps_before_restart := AuctionState.network_travel_steps
	AuctionState.start_chapter3()
	_expect(
		AuctionState.chapter3_people_book == people_before_restart,
		"chapter3_start_idempotent_people_book",
		failures
	)
	_expect(
		AuctionState.chapter3_poster_seen == poster_before_restart,
		"chapter3_start_idempotent_poster",
		failures
	)
	_expect(
		AuctionState.network_travel_steps == network_steps_before_restart,
		"chapter3_start_idempotent_network_steps",
		failures
	)

	# Public v0.1.3 saves do not contain any Sentana access keys.
	var legacy_v013 := before.duplicate(true)
	legacy_v013.erase("sentana_access_started")
	legacy_v013.erase("sentana_access_status")
	legacy_v013.erase("sentana_invitation_leads")
	legacy_v013.erase("sentana_invitation_source")
	var legacy_inventory: Dictionary = legacy_v013.get("inventory", {}).duplicate(true)
	legacy_inventory.erase("sentana_invitation")
	legacy_v013["inventory"] = legacy_inventory
	var legacy_rumors: Dictionary = legacy_v013.get("rumors", {}).duplicate(true)
	legacy_rumors.erase("sentana_invitation_required")
	legacy_v013["rumors"] = legacy_rumors
	AuctionState.import_save_data(legacy_v013)
	_expect(
		not AuctionState.sentana_access_started,
		"legacy_v013_sentana_access_defaults_not_started",
		failures
	)
	_expect(
		AuctionState.sentana_access_status == "not_started",
		"legacy_v013_sentana_status_default",
		failures
	)
	_expect(
		AuctionState.sentana_invitation_leads.is_empty(),
		"legacy_v013_sentana_leads_default",
		failures
	)
	_expect(
		not AuctionState.has_sentana_invitation(),
		"legacy_v013_no_invitation",
		failures
	)
	_expect(
		AuctionState.chapter3_poster_photographed,
		"legacy_v013_existing_poster_progress_kept",
		failures
	)
	_expect(
		AuctionState.has_inventory_item("sentana_photo"),
		"legacy_v013_existing_photo_kept",
		failures
	)
	_expect(
		AuctionState.start_sentana_access(),
		"legacy_v013_can_start_sentana_access",
		failures
	)
	_expect(
		AuctionState.sentana_access_status == "investigating",
		"legacy_v013_sentana_access_resumes_from_photo",
		failures
	)

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
