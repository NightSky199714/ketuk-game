extends Node

const TEST_PRIMARY := "user://ketuk_release_recovery_test.json"
const TEST_TMP := "user://ketuk_release_recovery_test.tmp"
const TEST_BACKUP := "user://ketuk_release_recovery_test.backup.json"

func _ready() -> void:
	var failures: Array[String] = []
	_cleanup()

	AuctionState.start_chapter1()
	AuctionState.money = 111111

	var payload_one := {
		"version": SaveManager.SAVE_VERSION,
		"resume_scene": "res://scenes/chapter/chapter1_home.tscn",
		"state": AuctionState.export_save_data()
	}

	_expect(
		SaveManager._write_payload_atomic(
			payload_one,
			TEST_PRIMARY,
			TEST_TMP,
			TEST_BACKUP
		),
		"first_atomic_write",
		failures
	)

	var first_primary := SaveManager._read_valid_payload(TEST_PRIMARY)
	_expect(
		int(first_primary.get("state", {}).get("money", -1)) == 111111,
		"first_primary_money",
		failures
	)

	AuctionState.money = 222222
	var payload_two := {
		"version": SaveManager.SAVE_VERSION,
		"resume_scene": "res://scenes/chapter/chapter2_batas.tscn",
		"state": AuctionState.export_save_data()
	}

	_expect(
		SaveManager._write_payload_atomic(
			payload_two,
			TEST_PRIMARY,
			TEST_TMP,
			TEST_BACKUP
		),
		"second_atomic_write",
		failures
	)

	var second_primary := SaveManager._read_valid_payload(TEST_PRIMARY)
	var rotated_backup := SaveManager._read_valid_payload(TEST_BACKUP)

	_expect(
		int(second_primary.get("state", {}).get("money", -1)) == 222222,
		"second_primary_money",
		failures
	)
	_expect(
		int(rotated_backup.get("state", {}).get("money", -1)) == 111111,
		"backup_preserves_previous_save",
		failures
	)

	_expect(
		SaveManager._write_text_file(TEST_PRIMARY, "{corrupt"),
		"corrupt_primary_write",
		failures
	)

	var recovered := SaveManager._best_valid_payload(
		TEST_PRIMARY,
		TEST_BACKUP
	)

	_expect(
		int(recovered.get("state", {}).get("money", -1)) == 111111,
		"backup_recovery_after_primary_corruption",
		failures
	)

	_cleanup()

	if failures.is_empty():
		print("SAVE_RECOVERY_OK")
		get_tree().quit(0)
		return

	for failure in failures:
		push_error("SAVE_RECOVERY_FAIL=" + failure)
	get_tree().quit(1)

func _cleanup() -> void:
	for path in [TEST_PRIMARY, TEST_TMP, TEST_BACKUP]:
		SaveManager._remove_file_if_present(path)

func _expect(condition: bool, label: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(label)
