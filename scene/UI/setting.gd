extends CanvasLayer

var preparing_for_capture = ""
var awaiting_input_for = ""
func _ready():
	update_keybinds_display()
	$info_panel.hide()
	pass # Replace with function body.

func _process(delta):
	if awaiting_input_for != "":
		var actions = GameInputMapper.get_actions_just_pressed()
		if actions.size() == 0:
			return
		GameInputMapper.set_input(awaiting_input_for,actions[0])
		awaiting_input_for = ""
		update_keybinds_display()
	if preparing_for_capture != "":
		awaiting_input_for = preparing_for_capture
		preparing_for_capture = ""
		$info_panel.hide()
		

func update_keybinds_display():
	$move_left_value.text = GameInputMapper.keybinds["move_left"][0]
	$move_right_value.text = GameInputMapper.keybinds["move_right"][0]
	$jump_value.text = GameInputMapper.keybinds["jump"][0]
	$shoot_value.text = GameInputMapper.keybinds["shoot"][0]
	$inventory_value.text = GameInputMapper.keybinds["inventory"][0]
	$skill_tree_value.text = GameInputMapper.keybinds["skill_tree"][0]
	

func prepare_for_key_capture(action_name):
	preparing_for_capture = action_name
	$info_panel.show()

func _on_move_left_value_button_down():
	prepare_for_key_capture("move_left")
	pass # Replace with function body.


func _on_move_right_value_button_down():
	prepare_for_key_capture("move_right")
	pass # Replace with function body.


func _on_jump_value_button_down():
	prepare_for_key_capture("jump")
	pass # Replace with function body.


func _on_shoot_value_button_down():
	prepare_for_key_capture("shoot")
	pass # Replace with function body.


func _on_inventory_value_button_down():
	prepare_for_key_capture("inventory")
	pass # Replace with function body.


func _on_skill_tree_value_button_down():
	prepare_for_key_capture("skill_tree")
	pass # Replace with function body.
