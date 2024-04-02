extends Node

enum keybindState {WAITING, PROCESSING, KEY_IN_USED, CHANGING}
var state = keybindState.WAITING
var current_action = ""

var pause_menu
var button_actions = [
	"move_left", "move_right", "jump", "shoot", 
	"inventory", "skill_tree", "light_attack", "heavy_attack", "hold_wall"
]
var button_values = {}

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match state:
		keybindState.WAITING:
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
	pause_menu.current_setting_tab_state = pause_menu.SettingTabState.MAIN


# Assuming GameInputMapper.set_input(action, key) takes a string for the action and the key code

func _input(event):
	if state == keybindState.CHANGING :
		# must be lowered and be in GameInputMapper.action array
		var key = event.as_text().to_lower()
		var old_key =  GameInputMapper.keybinds[current_action][0]
		if event is InputEventKey and key in GameInputMapper.actions:
			print(GameInputMapper.keybinds.values())
			for key_array in GameInputMapper.keybinds.values():
				if key_array[0] == key and key_array[0] != old_key:
					print("Key already in use")
					button_values[current_action].text = "Key already in use"
					state = keybindState.KEY_IN_USED
					return
			print("Current action: " + current_action)
			print("Key pressed: " + key)
			GameInputMapper.set_input(current_action, key)
			print(GameInputMapper.keybinds)
			# Update the button text
			button_values[current_action].text = key
			# Set the state back to WAITING
			state = keybindState.WAITING
			# unfocus the button
			button_values[current_action].release_focus()
			return
		# is mouse event assign the key to the action
		if event is InputEventMouseButton:
			# there were left click and right click
			if event.button_index == 1 or event.button_index == 2:
				print("Mouse " + str(event.button_index))
				# check if the key is already in use
				for key_array in GameInputMapper.keybinds.values():
					if key_array[0] == "left_mouse_button" and key_array[0] != old_key and event.button_index == 1:
						print("Key already in use")
						button_values[current_action].text = "Key already in use"
						state = keybindState.KEY_IN_USED
						return
					if key_array[0] == "right_mouse_button" and key_array[0] != old_key and event.button_index == 2:
						print("Key already in use")
						button_values[current_action].text = "Key already in use"
						state = keybindState.KEY_IN_USED
						return

				match event.button_index:
					1:
						GameInputMapper.set_input(current_action, "left_mouse_button")
						button_values[current_action].text = "left_mouse_button"
					2:
						GameInputMapper.set_input(current_action, "right_mouse_button")
						button_values[current_action].text = "right_mouse_button"
				# Set the state back to WAITING
				state = keybindState.WAITING
				button_values[current_action].release_focus()
				return
	
# check if user unfocus from the button
func _unhandled_input(event):
	if state == keybindState.CHANGING:
		state = keybindState.WAITING
		button_values[current_action].release_focus()
		button_values[current_action].text = GameInputMapper.keybinds[current_action][0]


func _on_change_keybind(action):
	print("Changing keybind for " + action)
	current_action = action
	button_values[action].text = "Press a key"
	# Set the state to CHANGING after a short delay to avoid immediate mouse click registration
	state = keybindState.PROCESSING
	await get_tree().create_timer(0.4)# Short delay
	state = keybindState.CHANGING

