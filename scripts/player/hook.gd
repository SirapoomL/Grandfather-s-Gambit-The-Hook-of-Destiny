extends Area2D
class_name Hook

@export var speed = 2000
@export var direction = Vector2(0,0)
@export var max_length = 600

var original_pos = Vector2(0, 0)
var hook_owner: Player

signal hook_break()
signal wall_hit(position)
signal hook_player_reached()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var hook_length = get_node("CollisionShape2D").global_position.distance_to(original_pos)
	render_chain()
	if hook_length > max_length:
		print("hook break: ori: ", original_pos, " this: ", get_node("CollisionShape2D").global_position, " len ", hook_length)
		hook_break.emit()
		queue_free()

func render_chain():
	rotation = position.angle_to_point(hook_owner.position)
	$Chain.region_rect.size.x = position.distance_to(hook_owner.position) / $Chain.scale.x
	
func dehook():
	visible = false

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
	if body is Player:
		hook_player_reached.emit()


func _on_timer_timeout():
	queue_free()
