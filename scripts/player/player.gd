extends CharacterBody2D
class_name Player
signal hit
signal shoot(direction, hold)
signal kill(mob)
signal finish_hook

const PlayerMovement = preload("player_movement.gd")
const PlayerAttack = preload("player_attack.gd")

enum State {DEAD, NORMAL, JUST_HOOKED, HOOKING, HOLD_HOOK, SWING}

@export var speed = 400
@export var jump_force = -450 # Usually jump force should be negative
@export var gravity = 980 # Adjust the gravity to your needs
@export var hook_speed = 1200
@export var hook_quota = 2
@export var hook_acc = 98*2
var screen_size # Size of the game window.
var jump_state = 3
var jump_quota = 3
var hook_count = 0
var hook_despawn_duration = 0.5
var state = State.DEAD
var shoot_hold_duration = 0.0
var hold_triggered = false
var hold_threshold = 0.13
var swing_hook: Hook

func _get_debug_hud():
	return get_tree().root.get_node("Main/DebugHud")

func start(pos):
	position = pos
	state = State.NORMAL
	show()
	$CollisionShape2D.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()
		
func change_state(s: State):
	if state == State.HOOKING:
		if s == State.NORMAL || s == State.JUST_HOOKED || s == State.SWING:
			hook_count -= 1
	#elif state == State.SWING:
		#if s == State.NORMAL || s == State.JUST_HOOKED :
			#hook_count -= 1
	state = s

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !GameState.is_playing():
		return

	if state == State.DEAD: return
	
	# Handling shoot
	# TODO: extract this as a method
	if GameInputMapper.is_action_just_released("shoot"):
		if swing_hook:
			swing_hook.queue_free()
			swing_hook = null
			
		if state == State.SWING:
			change_state(State.NORMAL)
		elif shoot_hold_duration <= hold_threshold:
			shoot_action(false)
		shoot_hold_duration = 0
		hold_triggered = false
	
	if GameInputMapper.is_action_pressed("shoot"):
		shoot_hold_duration += delta
		if not hold_triggered && shoot_hold_duration > hold_threshold:
			hold_triggered = true
			shoot_action(true)
			print("hold triggered")
		
	# process_movement(delta)
	PlayerAttack.new().process(self, delta)
	PlayerMovement.new().process(self, delta)
	_get_debug_hud().update_hook_count(hook_count)

func shoot_action(is_holding):
	# swing hook can't be duplicated
	if swing_hook && is_holding:
		return
	if hook_count < hook_quota:
		hook_count += 0 if is_holding else 1
		var cliclPos = get_local_mouse_position()
		var direction = cliclPos.normalized()
		shoot.emit(direction, is_holding)

func _on_wall_hooked(arg_position):
	print("on wall hooked", arg_position)
	if state == State.DEAD: return
	
	var direction = (arg_position - self.position).normalized()
	#print(direction)
	change_state(State.JUST_HOOKED)
	set_velocity(direction * hook_speed)
	
func set_swing_hook(sh: Hook):
	swing_hook = sh
	
func _on_wall_swing(arg_position):
	print("on wall swing", arg_position)
	if state == State.DEAD: return
	change_state(State.SWING)



func _on_attack_box_body_entered(body):
	print("attack")
	if body is Enemy or body is GroundEnemy:
		print("hit")
		kill.emit(body)
		body.queue_free()
