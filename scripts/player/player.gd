extends CharacterBody2D
class_name Player
signal dead
signal shoot(direction, hold)
signal kill(mob)
signal finish_hook

# State
enum State {DEAD, IDLE, RUN, LIGHT_ATTACK_1, LIGHT_ATTACK_2, HEAVY_ATTACK, 
JUMP, JUST_HOOKED, HOOKING, HOLD_HOOK, SWING, WALL_HOOK, HOOK_ATTACK,
BOUNCE, GLIDE}
const NORMAL_STATE = [State.IDLE, State.RUN, State.JUMP, State.GLIDE]
const ATTACK_STATE = [State.LIGHT_ATTACK_1, State.LIGHT_ATTACK_2, State.HEAVY_ATTACK, State.HOOK_ATTACK]
const HOOKING_STATE = [State.HOOKING, State.HOLD_HOOK, State.SWING, State.WALL_HOOK]
const UNAFFECTED_BY_INPUT = [ State.DEAD,
	State.LIGHT_ATTACK_1,State.LIGHT_ATTACK_2, State.HEAVY_ATTACK,
	State.BOUNCE
]
var state = State.DEAD
var screen_size # Size of the game window.
var state_lock_time = 0
var action_queue = []
var action_just_free = false
var face_left = false

# Movement
@export var speed = 400
@export var jump_force = -450 # Usually jump force should be negative
@export var strafe_force = 10
@export var air_terminal_velocity = 400
@export var gravity = 980 # Adjust the gravity to your needs
@export var hook_speed = 1200
@export var hook_quota = 2
@export var hook_acc = 98*2
@export var hook_cooldown = 2
@export var hook_power = 2000
var hang_time = 0.2
var jump_state = 3
var jump_quota = 3
var hook_count
var hook_despawn_duration = 0.5
var shoot_hold_duration = 0.0
var hold_triggered = false
var hold_threshold = 0.2
var swing_hook: Hook
var normal_hook: Hook
var oneway_platform_threshold = -300

# Combat
var max_hp = 100
var current_hp = 100
var attack_power = 20
var air_attack_qouta = 3
var hook_attack_qouta = 1
var exp = 0
var i_frame = 0
var max_i_frame = 1.25
var just_take_damage = 0

func get_debug_hud():
	return get_tree().root.get_node("Main/DebugHud")

func start(pos):
	current_hp = max_hp
	position = pos
	state = State.IDLE
	show()
	$CollisionShape2D.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hook_count = hook_quota
	screen_size = get_viewport_rect().size
	hide()
		
func change_state(s: State):
	if state_lock_time > 0:
		return false
	if state in HOOKING_STATE and s not in HOOKING_STATE:
		if is_instance_valid(normal_hook):
			normal_hook.dehook()
		if is_instance_valid(swing_hook):
			swing_hook.dehook()
	#if s == State.HOOKING:
		#velocity.x *= 0.6
		#velocity.y = 0
	if state in ATTACK_STATE:
		get_node("AttackBox/"+"LightAttack1"+"CollisionShape").set_deferred("disabled", false)
		get_node("AttackBox/"+"LightAttack2"+"CollisionShape").set_deferred("disabled", false)
		get_node("AttackBox/"+"HeavyAttack"+"CollisionShape").set_deferred("disabled", false)
	state = s
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#print(state)
	
	action_just_free = false
	var new_state_lock_time =  state_lock_time - delta if state_lock_time - delta > 0 else 0
	if new_state_lock_time < state_lock_time and new_state_lock_time == 0:
		action_just_free = true
		if state != State.BOUNCE:
			state = State.IDLE
	state_lock_time = new_state_lock_time
	if !GameState.is_playing():
		return

	if state == State.DEAD: return
	
	# Handling shoot
	# TODO: extract this as a method
	if GameInputMapper.is_action_just_released("shoot"):
		if swing_hook:
			swing_hook.queue_free()
			swing_hook = null
			
		change_state(State.IDLE)
		if shoot_hold_duration <= hold_threshold:
			shoot_action(false)
		shoot_hold_duration = 0
		hold_triggered = false
	
	if GameInputMapper.is_action_pressed("shoot"):
		shoot_hold_duration += delta
		if not hold_triggered && shoot_hold_duration > hold_threshold:
			change_state(State.IDLE)
			hold_triggered = true
			shoot_action(true)
			print("hold triggered")
			
	if hook_count < hook_quota:
		$HookHandler.timer_on(hook_cooldown)
	else:
		$HookHandler.timer_off()
		
	# process_movement(delta)
	process_hitbox_overlapped()
	get_node("CombatHandler").process(self, delta)
	get_node("MovementHandler").process(self, delta)
	get_debug_hud().update_hook_count(hook_count)
	get_debug_hud().update_hook_cooldown($HookHandler.get_time_left())
	get_debug_hud().update_player_position(global_position)
	get_debug_hud().get_node("PlayerState").text = "State: " + State.keys()[state]
	get_debug_hud().get_node("PlayerVelocity").text =  "Velocity: " + str(velocity)

func shoot_action(is_holding):
	# swing hook can't be duplicated
	if swing_hook && is_holding:
		return
	if hook_count:
		hook_count -= 1 # (for separate by hook type) 0 if is_holding else 1
		var hook_snap_pos = get_node("HookHandler").snap_pos
		var clickPos = get_local_mouse_position()
		if  hook_snap_pos != null :
			clickPos = Vector2(hook_snap_pos.x - global_position.x, hook_snap_pos.y - global_position.y) 
		var direction = clickPos.normalized()
		shoot.emit(direction, is_holding)

func _on_wall_hooked(arg_position):
	print("on wall hooked", arg_position)
	if state == State.DEAD: return
	
	#var direction = (arg_position - self.position).normalized()
	#print(direction)
	change_state(State.HOOKING)
		#set_velocity(direction * hook_speed)
	
func set_swing_hook(sh: Hook):
	if is_instance_valid(swing_hook):
		swing_hook.dehook()
	swing_hook = sh
	
func set_normal_hook(h: Hook):
	if is_instance_valid(normal_hook):
		normal_hook.dehook()
	normal_hook = h
	
func _on_wall_swing(arg_position):
	print("on wall swing", arg_position)
	if state == State.DEAD: return
	change_state(State.SWING)

func _on_hook_break(h:Hook):
	if state == State.SWING:
		state = State.IDLE
	if swing_hook:
		swing_hook = null
	if normal_hook:
		normal_hook = null
	h.queue_free()
	if state in HOOKING_STATE:
		change_state(State.IDLE)


func _on_attack_box_body_entered(body):
	print("Player trying to hit:", body.name.capitalize())
	if body is Enemy or body.name.to_lower().begins_with('ground_enemy'):
		var x = await body.hit(get_node("CombatHandler").get_attack_damage(attack_power, state, State))
		var damage_dealt = x[0]
		var exp_gained = x[1]
		if exp_gained != 0:
			body._self_kill()
		# do smth here
	if body is Minotaur:
		var x = await body.hit(get_node("CombatHandler").get_attack_damage(attack_power, state, State))
		var damage_dealt = x[0]
		var exp_gained = x[1]
		

func _on_check_area_area_exited(area):
	#if area.has_meta("oneway_platform"):
		#emerge_oneway_platform()
	if is_instance_valid(area) && is_instance_valid(normal_hook) && area == normal_hook:
		print("normal hook Exits")
		normal_hook.armed = true
	elif is_instance_valid(area) && is_instance_valid(swing_hook) && area == swing_hook:
		print("swing hook Exits")
		swing_hook.armed = true
	
		
func emerge_oneway_platform():
	if state in HOOKING_STATE or state == State.GLIDE:
		print("hooking over oneway platform")
		velocity.y = 0.6 * velocity.y
		velocity.y = min(velocity.y, oneway_platform_threshold)


func _on_check_area_area_entered(area):
	#if area is EventTriggerArea:
		#pass
	if area.has_meta("oneway_platform"):
		emerge_oneway_platform()
	if is_instance_valid(area) && is_instance_valid(normal_hook):
		if area.global_position == normal_hook.global_position:
			print("hook passed")
			change_state(State.GLIDE)
		
func die():
	hide()
	dead.emit()
	change_state(State.DEAD)
	get_node("CollisionShape2D").set_deferred("disabled", true)


func _on_hook_handler_hook_regenerated():
	if hook_count < hook_quota:
		hook_count += 1

func process_hitbox_overlapped():
	for area in $HitBoxArea2D.get_overlapping_areas():
			if area is Hazard and i_frame == 0:
				print("hazard hit")
				var hazard = area
				var incoming_pos_x = velocity.x
				if incoming_pos_x == 0:
					var rng = RandomNumberGenerator.new()
					incoming_pos_x = rng.randf_range(-10.0, 10.0)
				$CombatHandler.take_damage(self, area.damage, position.x + incoming_pos_x, 240)
