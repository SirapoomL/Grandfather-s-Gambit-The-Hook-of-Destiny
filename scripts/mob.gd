extends RigidBody2D
class_name Enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])
	pass # Replace with function body.

func _on_visible_on_screen_notifier_2d_screen_exited():
	#queue_free()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func self_kill():
	print("should be killed")
