extends CharacterBody2D
class_name DemoPlayer
signal hit

@export var speed = 400
@export var jump_force = -450 # Usually jump force should be negative
@export var gravity = 980 # Adjust the gravity to your needs
var screen_size # Size of the game window.
var jump_state
var jump_quota = 2

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.x = 0
	velocity.y += gravity*delta
	if Input.is_action_pressed("move_right"):
		velocity.x = speed
	if Input.is_action_pressed("move_left"):
		velocity.x = -speed
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump_state = 1
			velocity.y = jump_force
		elif  jump_state < jump_quota:
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


func _on_body_entered(body):
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	pass # Replace with function body.
