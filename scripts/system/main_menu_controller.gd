extends Control

@onready var continue_button: Button = $Margin/Root/ContinueButton
@onready var new_game_button: Button = $Margin/Root/NewGameButton
@onready var save_status: Label = $Margin/Root/SaveStatus
@onready var quit_button: Button = $Margin/Root/QuitButton
@onready var version_label: Label = $Margin/Root/Version
@onready var overwrite_dialog: ConfirmationDialog = $OverwriteDialog

func _ready() -> void:
	continue_button.pressed.connect(_continue_game)
	new_game_button.pressed.connect(_request_new_game)
	overwrite_dialog.confirmed.connect(_start_new_game)
	quit_button.pressed.connect(_quit_game)
	version_label.text = "v%s" % str(
		ProjectSettings.get_setting("application/config/version", "dev")
	)
	_refresh_save_state()

func _refresh_save_state() -> void:
	var health := SaveManager.save_health()
	continue_button.disabled = health == "none"

	match health:
		"primary":
			save_status.text = "Progress tersimpan tersedia."
		"backup":
			save_status.text = "Backup progress tersedia dan akan dipulihkan saat Lanjutkan."
		_:
			save_status.text = "Belum ada progress tersimpan."

func _continue_game() -> void:
	continue_button.disabled = true
	if not SaveManager.load_game():
		continue_button.disabled = false
		save_status.text = "Save tidak dapat dibaca. Game baru tetap bisa dimulai."

func _request_new_game() -> void:
	if SaveManager.has_valid_save():
		overwrite_dialog.popup_centered()
		return
	_start_new_game()

func _start_new_game() -> void:
	SaveManager.delete_save()
	SaveManager.new_game()


func _quit_game() -> void:
	get_tree().quit()
