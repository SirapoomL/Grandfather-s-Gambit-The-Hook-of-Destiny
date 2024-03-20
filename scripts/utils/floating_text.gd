extends Marker2D
class_name floating_text

var label
var amount = 0
var x_velo = 0
var y_velo = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	label = get_node("Label")
	label.set_text(str(amount))
	get_node("Timer").start()
	#x_velo = (randi_range(0,200)-100)/80
	y_velo = -2
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.y = global_position.y + y_velo
	global_position.x = global_position.x + x_velo
	pass


func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.
