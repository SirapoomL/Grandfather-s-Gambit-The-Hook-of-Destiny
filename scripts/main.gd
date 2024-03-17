extends Node

@export var mob_scene: PackedScene
@export var ground_enemy_spirit_scene: PackedScene
@export var hook: PackedScene
@export var swing_hook: PackedScene
var score
var ground_mob_count: int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_player_hit():
	game_over()
	pass # Replace with function body.

func game_over():
	print("game over")
	GameState.set_current_state(GameState.State.NOT_STARTED)
	$Music.stop()
	$DeathSound.play()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	ground_mob_count = 0
	print("game start")
	GameState.set_current_state(GameState.State.PLAYING)
	get_tree().call_group("mobs", "queue_free")
	#get_tree().call_group("GroundEnemy", "_self_kill") #TODO delete all ground enemy at the begining of the game
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	$Music.play()
	
func _on_mob_timer_timeout():
	if !GameState.is_playing():
		return
	# Create a new instance of the Mob scene.
	var ground_mob = ground_enemy_spirit_scene.instantiate()
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	#var mob_spawn_location = $StartPosition
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position
	ground_mob.position.x = mob_spawn_location.position.x

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	if (randi_range(0, 3) == 0):
		add_child(mob)
	
	# Spawn the ground mob by adding it to the Main scene.
	if (ground_mob_count < 3) and (randi_range(0, 5) == 0):
		ground_mob_count += 1
		add_child(ground_mob)
		print("Spawn ground mob:", ground_mob_count)
	
func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	print("timer start")

func _on_player_shoot(direction, is_holding):
	if is_holding:
		var sh = swing_hook.instantiate()
		sh.position = $Player.position
		sh.speed = 2000
		sh.direction = direction
		$Player.set_swing_hook(sh)
		sh.connect("wall_hit", Callable($Player, "_on_wall_swing"))
		add_child(sh)
		return
	
	var h = hook.instantiate()
	h.position = $Player.position
	h.speed = 2000
	h.direction = direction
	h.connect("wall_hit", Callable($Player, "_on_wall_hooked"))
	add_child(h)
