extends CharacterBody2D

class_name Minotaur

@export var speed : float = 200.0
@export var action_cooldown : int = 4
@export var cleave_cooldown : int = 5
@export var impale_cooldown : int = 3
@export var whirl_cooldown : int = 20

@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree : AnimationTree = $AnimationTree

# States
enum State {NORMAL, HIT, DEAD, CLEAVE, IMPALE, WHIRL_START, WHIRLING, WHIRL_END}
const MOVABLE_STATE = [State.NORMAL, State.WHIRLING]
const ATTACKABLE_STATE = [State.NORMAL]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : int = 0
var is_idle : bool = true
var state : State = State.NORMAL
var animation_playback : AnimationNodeStateMachinePlayback

signal facing_direction(facing_right : bool)

var action_cooldown_remaining : int = 0
var cleave_cooldown_remaining : int = 5
var impale_cooldown_remaining : int = 3
var whirl_cooldown_remaining : int = 10
var rng = RandomNumberGenerator.new()

func _ready():
	animation_tree.active = true
	animation_playback = animation_tree["parameters/playback"]

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if state == State.DEAD:
		move_and_slide()
		return
	
	var player = get_parent().get_node("Player")
	var player_direction = player.position - position
	
	if is_idle:
		if player_direction.length() > 1000:
			move_and_slide()
			return
		is_idle = false
	
	direction = 1 if (player_direction.x > 0) else -1
	
	if abs(player_direction.x) < 120 && state in ATTACKABLE_STATE:
		if action_cooldown_remaining < 0:
			action_cooldown_remaining = action_cooldown
			var random = rng.randf()
			if cleave_cooldown_remaining < 0 && random > 0.66:
				cleave_cooldown_remaining = cleave_cooldown
				animation_playback.travel("cleave")
				switch_state(State.CLEAVE)
			elif whirl_cooldown_remaining < 0 && random > 0.33:
				whirl_cooldown_remaining = whirl_cooldown
				animation_playback.travel("whirl_start")
				switch_state(State.WHIRL_START)
			elif impale_cooldown_remaining < 0:
				impale_cooldown_remaining = impale_cooldown
				animation_playback.travel("impale")
				switch_state(State.IMPALE)
		else:
			direction = 0
	
	if direction && state in MOVABLE_STATE:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	update_animation_params()
	update_facing_direction()
	
func update_animation_params():
	animation_tree.set("parameters/move/blend_position", direction)
	
func update_facing_direction():
	if state not in MOVABLE_STATE:
		return
	if direction > 0:
		sprite.flip_h = false
		collision.position.x = -3
	elif direction < 0:
		sprite.flip_h = true
		collision.position.x = 3
	emit_signal("facing_direction", !sprite.flip_h)
	
func _on_timer_timeout():
	action_cooldown_remaining -= 1
	cleave_cooldown_remaining -= 1
	impale_cooldown_remaining -= 1
	whirl_cooldown_remaining -= 1

func switch_state(next_state : State):
	state = next_state

func _on_animation_tree_animation_finished(anim_name):
	match(anim_name):
		"cleave":
			switch_state(State.NORMAL)
		"impale":
			switch_state(State.NORMAL)
		"whirl_start":
			switch_state(State.WHIRLING)
		"whirling":
			switch_state(State.WHIRL_END)
		"whirl_end":
			switch_state(State.NORMAL)
		"dead":
			queue_free()
