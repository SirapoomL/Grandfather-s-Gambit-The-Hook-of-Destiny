extends Node

var snap_pos = null

signal hook_regenerated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func timer_on(wait_time):
	if $HookRegenerate.is_stopped():
		$HookRegenerate.wait_time = wait_time
		$HookRegenerate.start()
		
func timer_off():
	if not $HookRegenerate.is_stopped():
		$HookRegenerate.stop()

func set_paused(paused):
	if paused:
		$HookRegenerate.paused = true
	else:
		$HookRegenerate.paused = false

func get_time_left():
	if not $HookRegenerate.is_stopped():
		return $HookRegenerate.time_left
	return 0


func _on_hook_regenerate_timeout():
	hook_regenerated.emit()

