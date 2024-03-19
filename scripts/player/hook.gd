extends Area2D
class_name Hook

@export var speed = 2000
@export var direction = Vector2(0,0)
@export var max_length = 680

var original_pos = Vector2(0, 0)

signal hook_break()
signal wall_hit(position)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var hook_length = get_node("CollisionShape2D").global_position.distance_to(original_pos)
	if hook_length > max_length:
		print("hook break: ori: ", original_pos, " this: ", get_node("CollisionShape2D").global_position, " len ", hook_length)
		hook_break.emit()
		queue_free()



func _physics_process(delta):
	position += direction * speed * delta




func _on_body_entered(body):
	if body is StaticTerrain:
		if body is StaticHookTerrain:
			wall_hit.emit(position)
			speed = 0
		else:
			hook_break.emit()
			queue_free()


func _on_timer_timeout():
	queue_free()
