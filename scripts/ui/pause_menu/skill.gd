extends Control

var player
var skill_point
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

var jump_quota_button
var hook_quota_button
var player_speed_button
var player_jump_button
var player_strafe_button
var gravity_button
var hook_speed_button
var hook_cooldown_button
var attack_power_button
var buttons


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/Main/Player")
	skill_point = $VBoxContainer/SkillpointContainer/MarginContainer2/SkillpointValue
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

	jump_quota_button = $VBoxContainer/StatContainer/MarginContainer2/VBoxContainer2/JumpLimitContainer/MarginContainer2/HBoxContainer/JumpQuotaButton
	hook_quota_button = $VBoxContainer/StatContainer/MarginContainer2/VBoxContainer2/HookLimitContainer/MarginContainer2/HBoxContainer/HookQuotaButton
	player_speed_button = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer/PlayerSpeed/HBoxContainer2/MarginContainer2/HBoxContainer/SpeedButton
	player_jump_button = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer/PlayerJump/HBoxContainer2/MarginContainer2/HBoxContainer/JumpButton
	player_strafe_button = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer/PlayerStrafe/HBoxContainer2/MarginContainer2/HBoxContainer/StrafeButton
	gravity_button = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer/Gravity/HBoxContainer2/MarginContainer2/HBoxContainer/GravityButton
	hook_speed_button = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer2/HookSpeed/HBoxContainer2/MarginContainer2/HBoxContainer/HookSpeedButton
	hook_cooldown_button = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer2/HookCooldown/HBoxContainer2/MarginContainer2/HBoxContainer/HookCooldownButton
	attack_power_button = $VBoxContainer/AttributeContainer/PanelContainer/HBoxContainer/VBoxContainer3/AttackPower/HBoxContainer2/MarginContainer2/HBoxContainer/AttackPowerButton
	buttons = [jump_quota_button, hook_quota_button, player_speed_button, player_jump_button, player_strafe_button, gravity_button, hook_speed_button, hook_cooldown_button, attack_power_button]

	hp.text = str(player.max_hp)
	jump_quota.text = str(player.jump_quota)
	hook_quota.text = str(player.hook_quota)
	skill_point.text = str(player.skill_point)

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
	hook_cooldown.text = str(player.hook_cooldown)
	attack_power.text = str(normalize(player.attack_power, "attack_power"))

	update_button(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if skill_point.text != str(player.skill_point):
		skill_point.text = str(player.skill_point)
		update_button()	
		update_stat()
		update_attribute()


func update_stat():
	hp.text = str(player.max_hp)
	jump_quota.text = str(player.jump_quota)
	hook_quota.text = str(player.hook_quota)

func update_attribute():
	player_speed.text = str(normalize(player.speed, "speed"))
	player_jump.text = str(normalize(player.jump_force, "jump"))
	player_strafe.text = str(normalize(player.strafe_force, "strafe"))
	gravity.text = str(normalize(player.gravity, "gravity"))
	hook_speed.text = str(normalize(player.hook_speed, "hook_speed"))
	hook_cooldown.text = str(player.hook_cooldown)
	attack_power.text = str(normalize(player.attack_power, "attack_power"))

func update_button(init=false):
	for button in buttons:
		var field_name = button.name
		var text = button.text
		# split the text
		var parts = text.split(" ")
		var value = float(parts[0])
		if player.skill_point < value:
			button.disabled = true
		else:
			button.disabled = false

		if field_name == "JumpQuotaButton":
			if player.jump_quota >= 5:
				button.disabled = true
				button.text = "Max"
		elif field_name == "HookQuotaButton":
			if player.hook_quota >= 5:
				button.disabled = true
				button.text = "Max"
		elif field_name == "HookCooldownButton":
			if player.hook_cooldown <= 0.5:
				button.disabled = true
				button.text = "Max"
		elif field_name == "AttackPowerButton":
			if player.attack_power >= 50:
				button.disabled = true
				button.text = "Max"
		
		if init:
			button.pressed.connect(on_button_pressed.bind(field_name,value))


func get_button(field_name):
	for button in buttons:
		if button.name == field_name:
			return button
	return null

func on_button_pressed(field_name, cost):
	print("Button pressed")
	if player.skill_point < cost:
		return
	player.skill_point -= cost
	print("Skill point: ", player.skill_point)
	var button = get_button(field_name)
	print("Button", button.name)
	var snake_field_name = convert_pascal_case_to_snake_case(field_name)
	print("Snake field name", snake_field_name)
	match snake_field_name:
		"jump_quota_button":
			player.jump_quota += 1
		"hook_quota_button":
			player.hook_quota += 1
		"speed_button":
			player.speed += 5
		"jump_button":
			player.jump_force -= 5
		"strafe_button":
			player.strafe_force += 1
		"gravity_button":
			player.gravity -= 10
		"hook_speed_button":
			player.hook_speed += 20
		"hook_cooldown_button":
			player.hook_cooldown -= 0.1
		"attack_power_button":
			player.attack_power += 1
		_:
			print("Invalid field name")

	button.set_focus_mode(Control.FOCUS_NONE)
	
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
	var max_value: float = max_values[field_name]
	print("Value", value)
	print("Max value", max_value)
	var normalized_value =  int((value / max_value) * 100)
	print("Normalized value", normalized_value)
	return str(normalized_value)
