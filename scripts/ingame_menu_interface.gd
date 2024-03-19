extends CanvasLayer
class_name Menu_Interface

enum NavbarState {
	CLOSE,
	MASTERY,
	WEAPONS_SKILLS,
	SETTING
}

var current_ui_state = NavbarState.CLOSE


var controls_button
var quit_to_menu_button
var quit_to_desktop_button


func _ready():
	# Initialize the UI to be closed
	hide_all()
	controls_button = $Control/TabContainer/Setting/MarginContainer/VBoxContainer/ControlsButton
	quit_to_menu_button = $Control/TabContainer/Setting/MarginContainer/VBoxContainer/QuitToMenuButton
	quit_to_desktop_button = $Control/TabContainer/Setting/MarginContainer/VBoxContainer/QuitToDesktopButton

	# Connect signals for buttons
	controls_button.connect("pressed", Callable(self, "_on_ControlsButton_pressed"))
	quit_to_menu_button.connect("pressed", Callable(self, "_on_QuitToMenuButton_pressed"))
	quit_to_desktop_button.connect("pressed", Callable(self, "_on_QuitToDesktopButton_pressed"))

func _process(delta):
	# Here, we'll just handle the toggling of the pause menu itself.
	# Assuming 'esc' is mapped to toggle the pause menu
	if GameInputMapper.is_action_just_pressed("esc"):
		toggle_pause()

func toggle_pause():
	if current_ui_state == NavbarState.CLOSE:
		show_pause_menu()
	else:
		hide_all()

func show_pause_menu():
	# Logic to show the pause menu
	visible = true
	current_ui_state = NavbarState.SETTING  # Set the initial state when the menu opens
	GameState.set_current_state(GameState.State.PAUSED)

func hide_all():
	# Logic to hide the pause menu and all its sub-menus
	visible = false
	current_ui_state = NavbarState.CLOSE
	GameState.set_current_state(GameState.State.PLAYING)

# Signal handlers for each button
func _on_MasteryButton_pressed():
	# Logic for showing mastery UI
	print("Mastery button pressed")
	pass

func _on_WeaponsSkillsButton_pressed():
	# Logic for showing weapons and skills UI
	print("Weapons and skills button pressed")
	pass

func _on_SettingsButton_pressed():
	# Logic for showing settings UI
	print("Settings button pressed")
	pass

func _on_ControlsButton_pressed():
	# Logic for controls UI or action
	print("Controls button pressed")
	pass

func _on_QuitToMenuButton_pressed():
	# Logic to quit to the game's main menu
	print("Quit to menu button pressed")
	pass

func _on_QuitToDesktopButton_pressed():
	# Logic to quit the game to desktop
	print("Quit to desktop button pressed")
	get_tree().quit()
