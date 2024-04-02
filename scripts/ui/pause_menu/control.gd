extends Node

enum keybindState {NORMAL, PROCESSING, KEY_IN_USED, CHANGING}
var state = keybindState.NORMAL
var current_action = ""

var pause_menu
var button_actions = [
	"move_left", "move_right", "jump", "shoot", 
	"inventory", "skill_tree", "light_attack", "heavy_attack", "hold_wall"
]
var button_values = {}
var old_mouse_position

func get_pascal_case(string):
	var words = string.split("_")
	var pascal_case = ""
	for word in words:
		pascal_case += word.capitalize()
	return pascal_case

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the pause menu
	pause_menu = get_node("/root/Main/Menu_Interface")
	# Connect back button signal
	$VBoxContainer/BackContainer/BackButton.connect("pressed", Callable(self, "_on_BackButton_pressed"))
	# Initialize key bind values
	for action in button_actions:
		var action_pascal = get_pascal_case(action)
		button_values[action] = $VBoxContainer/KeyBindContainer/ScrollContainer/HBoxContainer/AssignerContainer.get_node(action_pascal + "Value")
		button_values[action].text = GameInputMapper.keybinds[action][0]
	
	# Connect keybind change signals
	for action in button_actions:
		button_values[action].connect("pressed", func(): _on_change_keybind(action))
		# on release focus
		button_values[action].connect("focus_exited", func(): _unhandled_input(action))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match state:
		keybindState.NORMAL:
			pass
		keybindState.PROCESSING:
			# sleep for a frame
			await get_tree().create_timer(0.05).timeout
			state = keybindState.CHANGING
		keybindState.KEY_IN_USED:
			await get_tree().create_timer(0.05).timeout
			state = keybindState.CHANGING

# Called when the back button is pressed

func _on_BackButton_pressed():
	# reset all keybinds
	pause_menu.current_setting_tab_state = pause_menu.SettingTabState.MAIN

func _reset_keybinds():
	for action in button_actions:
		button_values[action].text = GameInputMapper.keybinds[action][0]

# Assuming GameInputMapper.set_input(action, key) takes a string for the action and the key code

func _input(event):
	if state != keybindState.CHANGING:
		return

	var key = ""
	var is_mouse_event = false
	var old_key = GameInputMapper.keybinds[current_action][0]

	# Determine input type and process accordingly
	# for keyboard only
	if event is InputEventKey:
		key = event.as_text().to_lower()
		if key == 'space':
			key = 'spacebar'
	# for mouse and click only
	elif event is InputEventMouseButton and event.button_index in [1, 2]:
		is_mouse_event = true
		key = "left_mouse_button" if event.button_index == 1 else "right_mouse_button" if event.button_index == 2 else ""

	# Check if the event is supported and key is in the action list (for keys)
	if not is_mouse_event and (key == "" or key not in GameInputMapper.actions):
		return

	# Check if the key or mouse button is already in use
	for key_array in GameInputMapper.keybinds.values():
		if key_array[0] == key and key_array[0] != old_key:
			print("Key already in use")
			button_values[current_action].text = "Key already in use"
			state = keybindState.KEY_IN_USED
			return

	# Assign the new key or mouse button
	print("Current action: " + current_action)
	print("Key: " + key)
	GameInputMapper.set_input(current_action, key)
	print(GameInputMapper.keybinds)

	# Update UI and state
	button_values[current_action].text = key
	state = keybindState.NORMAL
	button_values[current_action].release_focus()
	button_values[current_action].disabled = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_viewport().warp_mouse(old_mouse_position)

	
# check if user unfocus from the button
func _unhandled_input(_event):
	if state == keybindState.KEY_IN_USED:
		await get_tree().create_timer(1).timeout
	elif state == keybindState.CHANGING:
		button_values[current_action].text = "Press a key"

func _on_change_keybind(action):
	print("Changing keybind for " + action)
	current_action = action
	button_values[action].text = "Press a key"
	button_values[action].disabled = true
	# Set the state to CHANGING after a short delay to avoid immediate mouse click registration
	state = keybindState.PROCESSING
	await get_tree().create_timer(0.02).timeout# Short delay
	state = keybindState.CHANGING
	# remember mouse position
	old_mouse_position = get_viewport().get_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	


