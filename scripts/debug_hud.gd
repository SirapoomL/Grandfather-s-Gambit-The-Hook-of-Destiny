extends CanvasLayer
class_name DebugHud


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_hook_count(hc):
	$HookCountLabel.text = "Hook Count: " + str(hc)
