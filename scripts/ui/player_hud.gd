extends Control

var main
var player
var player_hud
var hook_regen_timer
var hp_bar
var info
var hook_logo
var jump_available
var hook_available
var jump_limit
var hook_limit
var jump_icon_art = preload("res://art/ui/player_hud/jump_icon.png") 
var hook_icon_art = preload("res://art/ui/player_hud/hook_icon.png")
var hook_countdown
var hook_handler
var level_bar
var level_text

var max_hp
var current_hp
var is_visible = false
# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_node("/root/Main")
	player = main.get_node("Player")
	player_hud = main.get_node("PlayerHud/PlayerHud")
	hp_bar = $HpBar
	info = $HpBar/Info
	hook_logo = $HookLimitBg/HookLogo
	jump_limit = $JumpLimitBg/JumpLimit
	hook_limit = $HookLimitBg/HookLimit
	hook_countdown = $HookLimitBg/HookCountdown
	hook_handler = player.get_node("HookHandler")
	level_bar = $LevelBar
	level_text = $LevelBar/Info
	
	# set max hp
	max_hp = player.max_hp
	hp_bar.max_value = max_hp
	set_player_hud_visibility(false)

	# set max hook cooldown
	hook_countdown.max_value = player.hook_cooldown

	jump_available = player.jump_quota - player.jump_state
	update_texture_rect(jump_limit, jump_icon_art, player.jump_quota , jump_available, Vector2(25, 25))
	hook_available = player.hook_quota - player.hook_count
	update_texture_rect(hook_limit, hook_icon_art, player.hook_quota, hook_available, Vector2(25, 25))

	# set level bar
	level_bar.max_value = player.max_exp
	level_text.text = str(player.level)
	level_bar.value = player.exp
	update_level_bar(player.exp, player.level)


	# connect signal
	player.connect("player_level_up", _on_level_up)

func set_player_hud_visibility(visible):
	player_hud.visible = visible
	is_visible = visible

func _process(delta):
	
	if GameState.get_current_state_str() not in ["PLAYING", "PAUSED"] :
		if is_visible:
			set_player_hud_visibility(false)
		return
	else:
		if not is_visible:
			set_player_hud_visibility(true)

	max_hp = player.max_hp
	update_hp_bar(player.current_hp)
	update_hook_countdown(hook_handler.get_time_left())


	jump_available = player.jump_quota - player.jump_state
	# print("updating jump available to " + str(player.jump_state) + " from " + str($JumpLimitBg.get_node("JumpLimit").get_child_count()))
	update_texture_rect(jump_limit, jump_icon_art, player.jump_quota, jump_available, Vector2(35, 35))

	hook_available = player.hook_count
	# print("updating hook available to " + str(player.hook_count) + " from " + str($HookLimitBg.get_node("HookLimit").get_child_count()))
	update_texture_rect(hook_limit, hook_icon_art,  player.hook_quota,  hook_available, Vector2(25, 25))

	# if hook is unavailable, change the matirial of the hook logo
	if player.hook_count == 0:
		hook_logo.modulate = Color(1, 1, 1, 0.5)
	else:
		hook_logo.modulate = Color(1, 1, 1, 1)
	

	# update level bar
	update_level_bar(player.exp, player.level)

func update_hp_bar(hp_value):
	hp_bar.value = hp_value
	hp_bar.max_value = max_hp
	# add text and round to 2 decimal places
	info.text = str(round(hp_value)) + " / " + str(round(max_hp))

func update_level_bar(exp, level):
	level_bar.value = exp
	level_bar.max_value = player.max_exp
	level_text.text = str(level)

func _on_level_up(level):
	print("level up to " + str(level))	

func update_hook_countdown(time):
	hook_countdown.value = time
	hook_countdown.max_value = player.hook_cooldown
	
func update_texture_rect(hbox, texture, org_amount, amount, rect_min_size):
	# First, remove all existing TextureRects

	for child in hbox.get_children():
		hbox.remove_child(child)
		child.queue_free() 

	if amount > 5:
		var texture_rect = create_texture_rect(texture, rect_min_size)
		hbox.add_child(texture_rect)
		var text = Label.new()
		text.text = " x " + str(amount)
		text.custom_minimum_size = rect_min_size
		hbox.add_child(text)
		return

	# Then, add new TextureRects based on the new_amount
	for i in range(org_amount):
		var texture_rect = create_texture_rect(texture, rect_min_size)
		# print("i: " + str(i) + " amount: " + str(amount) + " org_amount: " + str(org_amount))
		if i + 1 > amount:
			texture_rect.modulate = Color(1, 1, 1, 0.5)
		else:
			texture_rect.modulate = Color(1, 1, 1, 1)
		hbox.add_child(texture_rect)


func create_texture_rect(texture, rect_min_size):
	var texture_rect = TextureRect.new()
	texture_rect.texture = texture
	# change size of texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	texture_rect.custom_minimum_size = rect_min_size
	# use nearest filter to avoid blurring
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	# add material
	var material = ShaderMaterial.new()
	material.shader = preload("res://outline.gdshader")
	material.set_shader_parameter("color", Color(0, 0, 0, 1))
	material.set_shader_parameter("width", 1.398)
	texture_rect.material = material
	return texture_rect

