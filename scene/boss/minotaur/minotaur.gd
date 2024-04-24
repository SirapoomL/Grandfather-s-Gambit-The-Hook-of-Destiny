extends CharacterBody2D

class_name Minotaur

signal death

@export var speed : float = 200.0
@export var health : int = 200
@export var experience : int = 40

@export var attack_range : float = 35
@export var action_cooldown : int = 2
@export var cleave_cooldown : int = 6
@export var impale_cooldown : int = 4
@export var whirl_cooldown : int = 20
@export var stagger_cooldown : int = 5

@export var cleave_damage : int = 40
@export var impale_damage : int = 20
@export var whirl_damage : int = 40

@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree : AnimationTree = $AnimationTree

# States
enum State {NORMAL, HIT, DEAD, CLEAVE, IMPALE, WHIRL_START, WHIRLING, WHIRL_END}
const MOVABLE_STATE = [State.NORMAL, State.WHIRLING]
const ATTACKABLE_STATE = [State.NORMAL]
const IMPACTABLE_STATE = [State.NORMAL]

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
var stagger_cooldown_remaining : int = 0
var rng = RandomNumberGenerator.new()

var player_direction : Vector2

func _ready():
	animation_tree.active = true
	animation_playback = animation_tree["parameters/playback"]
	collision.disabled = false

func _physics_process(delta):
	if state == State.DEAD:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	var player = get_tree().root.get_node("Main/Player")
	player_direction = player.position - position
	
	if is_idle:
		move_and_slide()
		return
	
	direction = 1 if (player_direction.x > 0) else -1
	
	if abs(player_direction.x) < (attack_range * scale.x) && state in ATTACKABLE_STATE:
		if action_cooldown_remaining < 0:
			action_cooldown_remaining = 100
			var random = rng.randf()
			if cleave_cooldown_remaining < 0 && random > 0.66:
				switch_state(State.CLEAVE)
			elif whirl_cooldown_remaining < 0 && random > 0.33:
				switch_state(State.WHIRL_START)
			elif impale_cooldown_remaining < 0:
				switch_state(State.IMPALE)
			else:
				action_cooldown_remaining = 0
		else:
			direction = 0
	
	if direction && state in MOVABLE_STATE:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed/10)
	
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
	stagger_cooldown_remaining -= 1

func switch_state(next_state : State):
	match(next_state):
		State.HIT:
			velocity.x = 200 if player_direction.x < 0 else -200
			velocity.y = -100
			animation_playback.travel("hit")
		State.DEAD:
			collision.set_deferred("disabled", true)
			animation_playback.travel("dead")
		State.CLEAVE:
			cleave_cooldown_remaining = cleave_cooldown
			animation_playback.travel("cleave")
		State.IMPALE:
			impale_cooldown_remaining = impale_cooldown
			animation_playback.travel("impale")
		State.WHIRL_START:
			whirl_cooldown_remaining = whirl_cooldown
			animation_playback.travel("whirl_start")
		
	state = next_state

func _on_animation_tree_animation_finished(anim_name):
	match(anim_name):
		"cleave":
			action_cooldown_remaining = action_cooldown
			switch_state(State.NORMAL)
		"impale":
			action_cooldown_remaining = action_cooldown
			switch_state(State.NORMAL)
		"whirl_start":
			switch_state(State.WHIRLING)
		"whirling":
			switch_state(State.WHIRL_END)
		"whirl_end":
			action_cooldown_remaining = action_cooldown
			switch_state(State.NORMAL)
		"hit":
			switch_state(State.NORMAL)
		"dead":
			death.emit()
			queue_free()
func action():
	is_idle = false
	
func idle():
	is_idle = true

func hit(damage : int):
	if health <= 0:
		return [0, 0]
	
	var prev_health = health
	health -= damage
	
	if health <= 0:
		switch_state(State.DEAD)
		return [prev_health - health, experience]
	
	if state in IMPACTABLE_STATE:
		if stagger_cooldown_remaining < 0:
			stagger_cooldown_remaining = stagger_cooldown
			switch_state(State.HIT)
	
	return [prev_health - health, 0]
