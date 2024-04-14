extends Control

var player
var hp
var jump_quota
var hook_quota
var player_speed
var player_jump
var player_strafe
var gravity
var hook_speed
var hook_cooldown
var attack_power
var max_values = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/Main/Player")
	hp = $VBoxContainer/StatContainer/MarginContainer2/VBoxContainer2/HpContainer/MarginContainer2/HBoxContainer/Hp
	jump_quota = $VBoxContainer/StatContainer/MarginContainer2/VBoxContainer2/JumpLimitContainer/MarginContainer2/HBoxContainer/Jump
	hook_quota = $VBoxContainer/StatContainer/MarginContainer2/VBoxContainer2/HookLimitContainer/MarginContainer2/HBoxContainer/Hook
	player_speed = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer/PlayerSpeed/HBoxContainer2/MarginContainer2/HBoxContainer/MarginContainer/Speed
	player_jump = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer/PlayerJump/HBoxContainer2/MarginContainer2/HBoxContainer/MarginContainer/Jump
	player_strafe = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer/PlayerStrafe/HBoxContainer2/MarginContainer2/HBoxContainer/MarginContainer/Strafe
	gravity = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer/Gravity/HBoxContainer2/MarginContainer2/HBoxContainer/MarginContainer/Gravity
	hook_speed = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer2/HookSpeed/HBoxContainer2/MarginContainer2/HBoxContainer/MarginContainer/HookSpeed
	hook_cooldown = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer2/HookCooldown/HBoxContainer2/MarginContainer2/HBoxContainer/MarginContainer/HookCooldown
	attack_power = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer3/AttackPower/HBoxContainer2/MarginContainer2/HBoxContainer/MarginContainer/AttackPower

	hp.text = str(player.max_hp)
	jump_quota.text = str(player.jump_quota)
	hook_quota.text = str(player.hook_quota)

	max_values["hp"] = player.max_hp
	max_values["speed"] = player.speed
	max_values["jump"] = player.jump_force
	max_values["strafe"] = player.strafe_force
	max_values["gravity"] = player.gravity
	max_values["hook_speed"] = player.hook_speed
	max_values["hook_cooldown"] = player.hook_cooldown
	max_values["attack_power"] = player.attack_power

	player_speed.text = str(normalize(player.speed, "speed"))
	player_jump.text = str(normalize(player.jump_force, "jump"))
	player_strafe.text = str(normalize(player.strafe_force, "strafe"))
	gravity.text = str(normalize(player.gravity, "gravity"))
	hook_speed.text = str(normalize(player.hook_speed, "hook_speed"))
	hook_cooldown.text = str(normalize(player.hook_cooldown, "hook_cooldown"))
	attack_power.text = str(normalize(player.attack_power, "attack_power"))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	
func is_snake_case(value):
	return value.find("_") != -1

func convert_pascal_case_to_snake_case(value: String) -> String:
	var result: String = ""
	for i in range(value.length()):
		var ch: String = value[i]
		if ch in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ':
			if i > 0:
				result += "_"
			result += ch.to_lower()
		else:
			result += ch
	return result


func normalize(value, field_name):
	if !is_snake_case(field_name):
		field_name = convert_pascal_case_to_snake_case(field_name)
	var max_value = max_values[field_name]
	return (value / max_value) * 100
