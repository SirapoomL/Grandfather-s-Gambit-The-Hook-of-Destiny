extends StaticHookTerrain
class_name HookPoint


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_snap_range_mouse_entered():
	get_tree().root.get_node("Main/Player").get_node("HookHandler").snap_pos = get_node("SnapRange").global_position
	print("snapping: ", get_node("SnapRange").global_position)


func _on_snap_range_mouse_exited():
	get_tree().root.get_node("Main/Player").get_node("HookHandler").snap_pos = null
