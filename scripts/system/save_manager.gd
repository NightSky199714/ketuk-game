extends Node

const SAVE_PATH := "user://ketuk_save_v1.json"
const SAVE_TMP_PATH := "user://ketuk_save_v1.tmp"
const SAVE_BACKUP_PATH := "user://ketuk_save_v1.backup.json"
const SAVE_VERSION := 1
const DEFAULT_RESUME_SCENE := "res://scenes/chapter/chapter2_batas.tscn"

func has_save() -> bool:
	return (
		FileAccess.file_exists(SAVE_PATH)
		or FileAccess.file_exists(SAVE_BACKUP_PATH)
	)

func save_health() -> String:
	if not _read_valid_payload(SAVE_PATH).is_empty():
		return "primary"
	if not _read_valid_payload(SAVE_BACKUP_PATH).is_empty():
		return "backup"
	return "none"

func has_valid_save() -> bool:
	return save_health() != "none"

func save_game(scene_path: String = "") -> bool:
	if _release_check_mode():
		return true

	var resume_scene := scene_path
	if resume_scene.is_empty():
		var current := get_tree().current_scene
		if current != null:
			resume_scene = current.scene_file_path

	if not _is_safe_resume_scene(resume_scene):
		resume_scene = DEFAULT_RESUME_SCENE

	var payload := {
		"version": SAVE_VERSION,
		"resume_scene": resume_scene,
		"state": AuctionState.export_save_data()
	}

	return _write_payload_atomic(
		payload,
		SAVE_PATH,
		SAVE_TMP_PATH,
		SAVE_BACKUP_PATH
	)

func load_game() -> bool:
	var payload := _best_valid_payload(SAVE_PATH, SAVE_BACKUP_PATH)

	if payload.is_empty():
		push_error("No valid primary or backup save is available.")
		return false

	var state = payload.get("state", {})
	if typeof(state) != TYPE_DICTIONARY:
		push_error("Save state missing or invalid.")
		return false

	AuctionState.import_save_data(state)

	var resume_scene := str(payload.get("resume_scene", DEFAULT_RESUME_SCENE))
	if not _is_safe_resume_scene(resume_scene):
		resume_scene = DEFAULT_RESUME_SCENE

	get_tree().change_scene_to_file(resume_scene)
	return true

func new_game() -> void:
	AuctionState.reset_prototype()
	get_tree().change_scene_to_file("res://scenes/chapter/chapter1_intro.tscn")

func delete_save() -> bool:
	var ok := true
	for path in [SAVE_PATH, SAVE_TMP_PATH, SAVE_BACKUP_PATH]:
		if FileAccess.file_exists(path):
			ok = _remove_file_if_present(path) and ok
	return ok

func _write_payload_atomic(
	payload: Dictionary,
	primary_path: String,
	tmp_path: String,
	backup_path: String
) -> bool:
	if not _write_text_file(tmp_path, JSON.stringify(payload)):
		push_error("Unable to write temporary save file.")
		return false

	if _read_valid_payload(tmp_path).is_empty():
		push_error("Temporary save validation failed.")
		_remove_file_if_present(tmp_path)
		return false

	var primary_payload := _read_valid_payload(primary_path)
	var primary_was_valid := not primary_payload.is_empty()

	if FileAccess.file_exists(primary_path):
		if primary_was_valid:
			_remove_file_if_present(backup_path)
			var backup_error := _rename_user_file(
				primary_path.get_file(),
				backup_path.get_file()
			)
			if backup_error != OK:
				push_error("Unable to rotate current save into backup.")
				_remove_file_if_present(tmp_path)
				return false
		else:
			_remove_file_if_present(primary_path)

	var promote_error := _rename_user_file(
		tmp_path.get_file(),
		primary_path.get_file()
	)
	if promote_error != OK:
		push_error("Unable to promote temporary save.")
		if primary_was_valid and FileAccess.file_exists(backup_path):
			_rename_user_file(
				backup_path.get_file(),
				primary_path.get_file()
			)
		_remove_file_if_present(tmp_path)
		return false

	return true

func _best_valid_payload(primary_path: String, backup_path: String) -> Dictionary:
	var payload := _read_valid_payload(primary_path)
	if payload.is_empty():
		payload = _read_valid_payload(backup_path)
	return payload

func _read_valid_payload(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(parsed) != TYPE_DICTIONARY:
		return {}

	var payload: Dictionary = parsed
	if int(payload.get("version", 0)) != SAVE_VERSION:
		return {}

	if typeof(payload.get("state", null)) != TYPE_DICTIONARY:
		return {}

	return payload

func _write_text_file(path: String, text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.flush()
	file.close()
	return true

func _remove_file_if_present(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	var dir := DirAccess.open("user://")
	if dir == null:
		return false
	return dir.remove(path.get_file()) == OK

func _rename_user_file(from_name: String, to_name: String) -> Error:
	var dir := DirAccess.open("user://")
	if dir == null:
		return ERR_CANT_OPEN
	return dir.rename(from_name, to_name)

func _is_safe_resume_scene(scene_path: String) -> bool:
	return scene_path in [
		"res://scenes/chapter/chapter1_home.tscn",
		"res://scenes/chapter/chapter2_batas.tscn",
		"res://scenes/chapter/chapter3_orang_yang_tepat.tscn"
	]

func _release_check_mode() -> bool:
	return "release-check" in OS.get_cmdline_user_args()
