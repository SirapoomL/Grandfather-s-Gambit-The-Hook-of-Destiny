extends Control

var player
var hp
var jump_quota
var hook_quota
var attr_container

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/Main/Player")
	hp = $VBoxContainer/StatContainer/MarginContainer2/VBoxContainer2/HpContainer/MarginContainer2/HBoxContainer/Hp
	jump_quota = $VBoxContainer/StatContainer/MarginContainer2/VBoxContainer2/JumpLimitContainer/MarginContainer2/HBoxContainer/Jump
	hook_quota = $VBoxContainer/StatContainer/MarginContainer2/VBoxContainer2/HookLimitContainer/MarginContainer2/HBoxContainer/Hook
	hp.text = str(player.max_hp)
	jump_quota.text = str(player.jump_quota)
	hook_quota.text = str(player.hook_quota)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	
