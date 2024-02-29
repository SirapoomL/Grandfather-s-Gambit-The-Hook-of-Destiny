extends CharacterBody2D
class_name Player
signal hit
signal shoot(direction)
signal kill(mob)
signal finish_hook

enum State {DEAD, NORMAL, JUST_HOOKED, HOOKING, HOLD_HOOK}

@export var speed = 400
@export var jump_force = -450 # Usually jump force should be negative
@export var gravity = 980 # Adjust the gravity to your needs
@export var hook_speed = 1200
var screen_size # Size of the game window.
var jump_state = 3
var jump_quota = 3
var state = State.DEAD

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
	if state == State.HOOKING && s == State.NORMAL:
		finish_hook.emit()
	state = s
	
func process_animation(delta):
	if velocity.x != 0 and velocity.y != 0:
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "jump"
		$AnimatedSprite2D.flip_v = velocity.y > 0
		
func process_collision(delta):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is Enemy or collision.get_collider() is GroundEnemy:
			if state == State.HOOKING:
				print("hit")
				kill.emit(collision.get_collider())
				collision.get_collider().queue_free()
			else:
				hide()
				hit.emit()
				change_state(State.DEAD)
				$CollisionShape2D.set_deferred("disabled", true)
		elif state == State.HOOKING:
			change_state(State.NORMAL)
			velocity.y = 0
	
func process_movement(delta):
	#Handle Left Right Up Down
	match state:
		State.NORMAL:
			velocity.x = 0
			velocity.y += gravity*delta
			if is_on_floor():
				change_state(State.NORMAL)
				jump_state = 0
			if GameInputMapper.is_action_pressed("move_right"):
				velocity.x = speed
			if GameInputMapper.is_action_pressed("move_left"):
				velocity.x = -speed
		State.JUST_HOOKED:
			change_state(State.HOOKING)
		
	#Handle Jump
	if GameInputMapper.is_action_just_pressed("jump") and jump_state < jump_quota:
		change_state(State.NORMAL)
		jump_state += 1
		velocity.y = jump_force
		#position += velocity * delta
		#position = position.clamp(Vector2.ZERO, screen_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !GameState.is_playing():
		return

	if state == State.DEAD: return
	
	if GameInputMapper.is_action_just_pressed("shoot"):
		var cliclPos = get_local_mouse_position()
		var direction = cliclPos.normalized()
		shoot.emit(direction)
	
	process_movement(delta)
	move_and_slide()

	process_collision(delta)
	
	process_animation(delta)

func _on_wall_hooked(arg_position):
	print("on wall hooked", arg_position)
	if state == State.DEAD: return
	
	var direction = (arg_position - self.position).normalized()
	#print(direction)
	change_state(State.JUST_HOOKED)
	set_velocity(direction * hook_speed)
	

