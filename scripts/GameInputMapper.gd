extends Node

var actions = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", 
	"m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", 
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
	"[", "]", ";", "'", ",", ".", "slash", "back_slash", "enter", "shift",
	"left_mouse_button", "right_mouse_button", "spacebar", "esc", "tab"];


var keybinds = {
	"inventory": ["i"],
	"skills": ["tab"],
	"mastery": ["p"],
	"move_left": ["a", "left_arrow"],
	"move_right": ["d", "right_arrow"],
	"jump": ["w","spacebar"],
	"esc": ["esc"],
	"shoot": ["r"],
	"interact": ["e"],
	"light_attack": ["left_mouse_button"],
	"heavy_attack": ["right_mouse_button"],
	"hold_wall": ["shift"], 
}

func is_action_just_pressed(input):
	for key in keybinds[input]:
		if Input.is_action_just_pressed(key):
			return true
	return false

func is_action_just_pressed_in(inputs: Array[String]):
	for input in inputs:
		for key in keybinds[input]:
			if Input.is_action_just_pressed(key):
				return true
	return false

func is_action_just_released(input):
	for key in keybinds[input]:
		if Input.is_action_just_released(key):
			return true
	return false

func is_action_pressed(input):
	for key in keybinds[input]:
		if Input.is_action_pressed(key):
			return true
	return false
	
func is_action_pressed_in(inputs: Array[String]):
	for input in inputs:
		for key in keybinds[input]:
			if Input.is_action_pressed(key):
				return true
	return false

func get_actions_just_pressed():
	var action_list = []
	for action in actions:
		if Input.is_action_just_pressed(action):
			action_list.append(action)
	return action_list
	
func set_input(target,input):
	keybinds[target][0] = input

func get_key_pressed():
	for action in actions:
		if Input.is_action_just_pressed(action):
			return action
	return null
