extends Control

var player
var jump_quota
var hook_quota

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("/root/Main/Player")
	jump_quota = $VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/HBoxContainer2/MarginContainer2/PlayerJump
	hook_quota = $VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/HBoxContainer3/MarginContainer2/PlayerHook

	jump_quota.text = str(player.jump_quota)
	hook_quota.text = str(player.hook_quota)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
