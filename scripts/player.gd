extends CharacterBody2D
class_name Player
signal hit
signal shoot

@export var speed = 400
@export var jump_force = -450 # Usually jump force should be negative
@export var gravity = 980 # Adjust the gravity to your needs
var screen_size # Size of the game window.
var jump_state
var jump_quota = 3
var state = 'normal'
var clickPos

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print(event.position)
			clickPos = event.position
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = 0
	velocity.y += gravity*delta
	
	if Input.is_action_just_pressed("shoot"):
		shoot.emit(clickPos)
		print("shoot")
	
	if is_on_floor():
		state = 'normal'
		jump_state = 0
	if state == 'normal' and Input.is_action_pressed("move_right"):
		velocity.x = speed
	if state == 'normal' and Input.is_action_pressed("move_left"):
		velocity.x = -speed
	if Input.is_action_just_pressed("jump") and jump_state < jump_quota:
		state = 'normal'
		jump_state += 1
		velocity.y = jump_force
	#position += velocity * delta
	#position = position.clamp(Vector2.ZERO, screen_size)
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is Enemy:
			hide()
			hit.emit()
			$CollisionShape2D.set_deferred("disabled", true)
	
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
	pass

#func shoot():
	#pass

