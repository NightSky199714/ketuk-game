extends Node

const SAVE_PATH := "user://ketuk_save_v1.json"
const SAVE_VERSION := 1
const DEFAULT_RESUME_SCENE := "res://scenes/chapter/chapter2_batas.tscn"

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func has_valid_save() -> bool:
	if not has_save():
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	var payload: Dictionary = parsed
	if int(payload.get("version", 0)) != SAVE_VERSION:
		return false

	return typeof(payload.get("state", null)) == TYPE_DICTIONARY

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

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to open save file for writing.")
		return false

	file.store_string(JSON.stringify(payload))
	file.close()
	return true

func load_game() -> bool:
	if not has_save():
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Unable to open save file.")
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Save file is not a valid dictionary.")
		return false

	var payload: Dictionary = parsed
	if int(payload.get("version", 0)) != SAVE_VERSION:
		push_error("Unsupported save version.")
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
	if not has_save():
		return true
	return DirAccess.remove_absolute(SAVE_PATH) == OK

func _is_safe_resume_scene(scene_path: String) -> bool:
	return scene_path in [
		"res://scenes/chapter/chapter1_home.tscn",
		"res://scenes/chapter/chapter2_batas.tscn",
		"res://scenes/chapter/chapter3_orang_yang_tepat.tscn"
	]


func _release_check_mode() -> bool:
	return "release-check" in OS.get_cmdline_user_args()
