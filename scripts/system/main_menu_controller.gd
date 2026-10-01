extends Control

@onready var continue_button: Button = $Margin/Root/ContinueButton
@onready var new_game_button: Button = $Margin/Root/NewGameButton
@onready var save_status: Label = $Margin/Root/SaveStatus
@onready var overwrite_dialog: ConfirmationDialog = $OverwriteDialog

func _ready() -> void:
	continue_button.pressed.connect(_continue_game)
	new_game_button.pressed.connect(_request_new_game)
	overwrite_dialog.confirmed.connect(_start_new_game)
	_refresh_save_state()

func _refresh_save_state() -> void:
	var has_save := SaveManager.has_save()
	continue_button.disabled = not has_save
	save_status.text = "Progress tersimpan tersedia." if has_save else "Belum ada progress tersimpan."

func _continue_game() -> void:
	continue_button.disabled = true
	if not SaveManager.load_game():
		continue_button.disabled = false
		save_status.text = "Save tidak dapat dibaca. Game baru tetap bisa dimulai."

func _request_new_game() -> void:
	if SaveManager.has_save():
		overwrite_dialog.popup_centered()
		return
	_start_new_game()

func _start_new_game() -> void:
	SaveManager.delete_save()
	SaveManager.new_game()
