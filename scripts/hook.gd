extends Area2D
class_name Hook

@export var speed = 2000
@export var direction = Vector2(0,0)

signal wall_hit(position)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func _physics_process(delta):
	position += direction * speed * delta




func _on_body_entered(body):
	if body is StaticTerrain:
		if body is StaticHookTerrain:
			wall_hit.emit(position)
			speed = 0
		else:
			#TODO: break hook
			pass


func _on_timer_timeout():
	queue_free()
