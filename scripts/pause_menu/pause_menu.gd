extends CanvasLayer
class_name PauseMenu

enum NavbarState {
	CLOSE,
	MASTERY,
	WEAPONS_SKILLS,
	SETTING
}

enum SettingTabState {
	MAIN,
	IN_CONTROL,
}

var main
var current_ui_state = NavbarState.CLOSE
var current_setting_tab_state = SettingTabState.MAIN

var tab_container
var mastery_tab
var weapons_skills_tab
var setting_tab

var setting_container
var control_container
var keybind 


func _ready():
	main = get_node("/root/Main")

	# Initialize the UI to be closed
	current_ui_state = NavbarState.CLOSE
	tab_container = $Control/TabContainer
	mastery_tab = $Control/TabContainer/Mastery
	weapons_skills_tab = $Control/TabContainer/Skill
	setting_tab = $Control/TabContainer/Setting
	setting_container = $Control/TabContainer/Setting/SettingContainer
	control_container = $Control/TabContainer/Setting/ControlContainer
	# Connect signals for tabs container
	tab_container.connect("tab_changed",Callable(self, "_on_Tab_Changed"))

func _process(delta):
	if GameState.get_current_state() == GameState.State.NOT_STARTED or control_container.state != control_container.keybindState.NORMAL:
		return
	if GameInputMapper.is_action_just_pressed("esc"):
		main.toggle_pause()
		prepare_pause_menu()
		toggle_pause()

	# do state for pause menu
	match current_ui_state:
		NavbarState.CLOSE:
			hide_pause_menu()
		NavbarState.MASTERY:
			# Show the mastery tab
			mastery_tab.visible = true
		NavbarState.WEAPONS_SKILLS:
			# Show the weapons and skills tab
			weapons_skills_tab.visible = true
		NavbarState.SETTING:
			# Show the setting tab
			show_pause_menu()
			setting_tab.visible = true
			# do state for setting tab
			match current_setting_tab_state:
				SettingTabState.MAIN:
					# Hide control container
					setting_container.visible = true
					control_container.visible = false
				SettingTabState.IN_CONTROL:
					# Show control container
					setting_container.visible = false
					control_container.visible = true

func _on_Tab_Changed(tab_index):
	# Handle the tab change event
	match tab_index:
		0:  
			_on_Mastery_pressed()
		1:  
			_on_WeaponsSkills_pressed()
		2:  
			_on_Setting_pressed()

func prepare_pause_menu():
	# Logic to prepare the pause menu
	# hide control container
	current_setting_tab_state = SettingTabState.MAIN

func toggle_pause():
	if current_ui_state == NavbarState.CLOSE:
		current_ui_state = NavbarState.SETTING
	else:
		current_ui_state = NavbarState.CLOSE

func show_pause_menu():
	# Logic to show the pause menu
	visible = true
	GameState.set_current_state(GameState.State.PAUSED)

func hide_pause_menu():
	# Logic to hide the pause menu and all its sub-menus
	visible = false
	GameState.set_current_state(GameState.State.PLAYING)


func _on_Mastery_pressed():
	# Logic for mastery UI or action
	current_ui_state = NavbarState.MASTERY
	print("Mastery button pressed")

func _on_WeaponsSkills_pressed():
	# Logic for weapons and skills UI or action
	current_ui_state = NavbarState.WEAPONS_SKILLS
	print("Weapons and skills button pressed")

func _on_Setting_pressed():
	# Logic for setting UI or action
	prepare_pause_menu()
	current_ui_state = NavbarState.SETTING
	print("Setting button pressed")

