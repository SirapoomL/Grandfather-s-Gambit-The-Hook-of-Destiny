extends MarginContainer
var main
var pause_menu
var controls_button
var quit_to_menu_button
var quit_to_desktop_button

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get main file
	main = get_node("/root/Main")
	# Get the pause menu
	pause_menu = get_node("/root/Main/Menu_Interface")
	# Get the buttons
	controls_button = $VBoxContainer/ControlsButton
	quit_to_menu_button = $VBoxContainer/QuitToMenuButton
	quit_to_desktop_button = $VBoxContainer/QuitToDesktopButton
	# Connect signals for buttons
	controls_button.connect("pressed", Callable(self, "_on_ControlsButton_pressed"))
	quit_to_menu_button.connect("pressed", Callable(self, "_on_QuitToMenuButton_pressed"))
	quit_to_desktop_button.connect("pressed", Callable(self, "_on_QuitToDesktopButton_pressed"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_ControlsButton_pressed():
	# Logic for controls UI or action
	pause_menu.current_setting_tab_state = pause_menu.SettingTabState.IN_CONTROL
	print("Controls button pressed")

func _on_QuitToMenuButton_pressed():
	# Logic to quit to the game's main menu
	# TODO: add a confirmation dialog
	print("Quit to menu button pressed")
	pause_menu.current_ui_state = pause_menu.NavbarState.CLOSE
	# wait 0.05 second before going back to the main menu
	await get_tree().create_timer(0.05).timeout  
	main.main_menu()
	


func _on_QuitToDesktopButton_pressed():
	# Logic to quit the game to desktop
	# TODO: add a confirmation dialog
	print("Quit to desktop button pressed")
	get_tree().quit()
