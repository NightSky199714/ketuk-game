extends Node

const DATA_PATH := "res://data/npcs/prototype_npcs.json"

var npcs: Dictionary = {}

func _ready() -> void:
	_load_data()

func _load_data() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		push_error("NPC data not found: %s" % DATA_PATH)
		return

	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("NPC data is invalid JSON.")
		return

	npcs = parsed

func get_npc(npc_id: String) -> Dictionary:
	return npcs.get(npc_id, {})

func get_display_name(npc_id: String) -> String:
	var npc := get_npc(npc_id)
	return str(npc.get("display_name", npc_id))
