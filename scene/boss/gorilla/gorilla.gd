extends CharacterBody2D

class_name Gorilla

@export var speed : float = 200.0
@export var charge_speed : float = 350.0
@export var health : int = 1000
@export var experience : int = 100

@export var melee_range : float = 35
@export var charge_range : float = 250
@export var min_dive_range : float = 100
@export var max_dive_range : float = 300
@export var provoke_range : float = 200

@export var action_cooldown : int = 2
@export var counter_cooldown : int = 10
@export var slam_cooldown : int = 4
@export var charge_cooldown : int = 10
@export var dive_cooldown : int = 15
@export var triple_dive_cooldown : int = 20
@export var provoke_cooldown : int = 10
@export var stagger_cooldown : int = 4

@export var counter_damage : int = 40
@export var slam_damage : int = 30
@export var charge_damage : int = 20
@export var dive_damage : int = 40
@export var dive_midair_damage : int = 20
@export var triple_dive_damage : int = 40
@export var triple_dive_midair_damage : int = 20

@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree : AnimationTree = $AnimationTree

# States
enum State {NORMAL, HIT, DEAD, PROVOKE, COUNTER, SLAM, 
	CHARGE_START, CHARGE, CHARGE_END, 
	DIVE_START, DIVE_MIDAIR, DIVE_LANDING,
	TRIPLE_DIVE_START, TRIPLE_DIVE_MIDAIR, TRIPLE_DIVE_LANDING,}
const MOVABLE_STATE = [State.NORMAL, State.CHARGE, State.DIVE_MIDAIR, State.TRIPLE_DIVE_MIDAIR]
const TURNABLE_STATE = [State.NORMAL, State.DIVE_LANDING, State.TRIPLE_DIVE_LANDING]
const ATTACKABLE_STATE = [State.NORMAL]
const IMPACTABLE_STATE = [State.NORMAL, State.PROVOKE]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : int = 0
var is_idle : bool = false
var state : State = State.NORMAL
var animation_playback : AnimationNodeStateMachinePlayback

signal facing_direction(facing_right : bool)

var action_cooldown_remaining : int = 0
var counter_cooldown_remaining : int = 0
var slam_cooldown_remaining : int = 0
var charge_cooldown_remaining : int = 5
var dive_cooldown_remaining : int = 5
var triple_dive_cooldown_remaining : int = 10
var provoke_cooldown_remaining : int = 10
var stagger_cooldown_remaining : int = 0

var is_midair : bool = false
var dive_count : int = 0

var player_direction : Vector2

func _ready():
	animation_tree.active = true
	animation_playback = animation_tree["parameters/playback"]
	collision.disabled = false

func _physics_process(delta):
	if state == State.DEAD:
		return
	
	if is_on_floor():
		if is_midair:
			landing()
		is_midair = false
	else:
		is_midair = true
		velocity.y += gravity * delta
		
	var player = get_tree().root.get_node("Main/Player")
	player_direction = player.position - position
	
	if is_idle:
		move_and_slide()
		return
	
	if state in TURNABLE_STATE:
		direction = 1 if (player_direction.x > 0) else -1
	
	#if abs(player_direction.x) < (attack_range * scale.x) && state in ATTACKABLE_STATE:
	if state in ATTACKABLE_STATE:
		if action_cooldown_remaining < 0:
			action_cooldown_remaining = 100
			var doable = []
			if player_direction.y > -50:
				if slam_cooldown_remaining < 0 && abs(player_direction.x) < (melee_range * scale.x):
					doable.append(State.SLAM)
				if charge_cooldown_remaining < 0 && abs(player_direction.x) < (charge_range * scale.x):
					doable.append(State.CHARGE_START)
				if dive_cooldown_remaining < 0 && (min_dive_range * scale.x) < abs(player_direction.x) && abs(player_direction.x) < (max_dive_range * scale.x):
					doable.append(State.DIVE_START)
				if triple_dive_cooldown_remaining < 0 && (min_dive_range * scale.x) < abs(player_direction.x) && abs(player_direction.x) < (max_dive_range * scale.x):
					doable.append(State.TRIPLE_DIVE_START)
				if provoke_cooldown_remaining < 0 && abs(player_direction.x) > (provoke_range * scale.x):
					doable.append(State.PROVOKE)
			else:
				if dive_cooldown_remaining < 0 && abs(player_direction.x) < (max_dive_range * scale.x):
					doable.append(State.DIVE_START)
				if triple_dive_cooldown_remaining < 0 && abs(player_direction.x) < (max_dive_range * scale.x):
					doable.append(State.TRIPLE_DIVE_START)
				if provoke_cooldown_remaining < 0:
					doable.append(State.PROVOKE)
			if doable.size() > 0:
				update_facing_direction()
				switch_state(doable.pick_random())
			else:
				action_cooldown_remaining = 0
		elif abs(player_direction.x) < (melee_range * scale.x):
			direction = 0
	
	if direction && state in MOVABLE_STATE:
		if state not in [State.DIVE_MIDAIR, State.TRIPLE_DIVE_MIDAIR]:
			velocity.x = direction * (speed if state != State.CHARGE else charge_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, speed/10)
	
	move_and_slide()
	update_animation_params()
	update_facing_direction()
	
func update_animation_params():
	animation_tree.set("parameters/move/blend_position", direction)
	
func update_facing_direction():
	var facing = direction if state != State.PROVOKE else -direction
	if facing > 0:
		sprite.flip_h = false
	elif facing < 0:
		sprite.flip_h = true
	emit_signal("facing_direction", !sprite.flip_h)
	
func _on_timer_timeout():
	action_cooldown_remaining -= 1
	counter_cooldown_remaining -= 1
	slam_cooldown_remaining -= 1
	charge_cooldown_remaining -= 1
	dive_cooldown_remaining -= 1
	triple_dive_cooldown_remaining -= 1
	provoke_cooldown_remaining -= 1
	stagger_cooldown_remaining -= 1

func switch_state(next_state : State):
	match(next_state):
		State.HIT:
			velocity.x = 200 if player_direction.x < 0 else -200
			velocity.y = -100
			stagger_cooldown_remaining = stagger_cooldown
			animation_playback.travel("hit")
		State.DEAD:
			collision.set_deferred("disabled", true)
			animation_playback.travel("dead")
		State.COUNTER:
			stagger_cooldown_remaining = stagger_cooldown
			animation_playback.travel("counter")
		State.PROVOKE:
			provoke_cooldown_remaining = provoke_cooldown
			animation_playback.travel("provoke")
		State.SLAM:
			slam_cooldown_remaining = slam_cooldown
			animation_playback.travel("slam")
		State.CHARGE_START:
			charge_cooldown_remaining = charge_cooldown
			animation_playback.travel("charge_start")
		State.DIVE_START:
			dive_cooldown_remaining = dive_cooldown
			animation_playback.travel("dive_start")
		State.DIVE_MIDAIR:
			velocity = get_init_dive_velocity()
			update_facing_direction()
		State.TRIPLE_DIVE_START:
			triple_dive_cooldown_remaining = triple_dive_cooldown
			dive_count = 0
			animation_playback.travel("triple_dive_start")
		State.TRIPLE_DIVE_MIDAIR:
			velocity = get_init_dive_velocity()
			update_facing_direction()
			dive_count += 1
		
	state = next_state

func _on_animation_tree_animation_finished(anim_name):
	match(anim_name):
		"slam":
			action_cooldown_remaining = action_cooldown
			switch_state(State.NORMAL)
		"charge_start":
			switch_state(State.CHARGE)
		"charge":
			switch_state(State.CHARGE_END)
		"charge_end":
			action_cooldown_remaining = action_cooldown
			switch_state(State.NORMAL)
		"dive_start":
			switch_state(State.DIVE_MIDAIR)
		"dive_bomb":
			action_cooldown_remaining = action_cooldown
			switch_state(State.NORMAL)
		"triple_dive_start":
			switch_state(State.TRIPLE_DIVE_MIDAIR)
		"triple_dive_bomb":
			if dive_count < 3:
				animation_playback.travel("triple_dive_jump")
				switch_state(State.TRIPLE_DIVE_MIDAIR)
			else:
				animation_playback.travel("triple_dive_end")
				switch_state(State.TRIPLE_DIVE_LANDING)
		"triple_dive_end":
			dive_count = 0
			action_cooldown_remaining = action_cooldown
			switch_state(State.NORMAL)
		"counter":
			action_cooldown_remaining = action_cooldown
			switch_state(State.NORMAL)
		"provoke":
			action_cooldown_remaining = action_cooldown
			switch_state(State.NORMAL)
		"hit":
			switch_state(State.NORMAL)
		"dead":
			queue_free()

func action():
	is_idle = false
	
func idle():
	is_idle = true
	
func landing():
	match(state):
		State.DIVE_MIDAIR:
			switch_state(State.DIVE_LANDING)
			animation_playback.travel("dive_bomb")
		State.TRIPLE_DIVE_MIDAIR:
			switch_state(State.TRIPLE_DIVE_LANDING)
			animation_playback.travel("triple_dive_bomb")

func get_init_dive_velocity():
	var dive_velocity = Vector2(0, 0)
	if player_direction.y > -50:
		dive_velocity.y = -600
		dive_velocity.x = player_direction.x * 0.8
		return dive_velocity
	dive_velocity.y = min(-600, max(-1500, (player_direction.y+50) * 2))
	dive_velocity.x = player_direction.x
	return dive_velocity

func hit(damage : int):
	if health <= 0:
		return [0, 0]
	
	var prev_health = health
	health -= damage
	
	if health <= 0:
		switch_state(State.DEAD)
		return [prev_health - health, experience]
	
	if state in IMPACTABLE_STATE:
		print(randf())
		print(action_cooldown_remaining < 0)
		print(counter_cooldown_remaining < 0)
		print(randf() < 0.3)
		if stagger_cooldown_remaining < 0 && counter_cooldown_remaining < 0 && randf() < 0.4:
			switch_state(State.COUNTER)
		elif stagger_cooldown_remaining < 0:
			switch_state(State.HIT)
	
	return [prev_health - health, 0]
