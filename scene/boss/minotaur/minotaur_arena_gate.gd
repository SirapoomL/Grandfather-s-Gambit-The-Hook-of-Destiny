extends Node
class_name MinotaurArenaGate


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_minotaur_gate_timer_timeout():
	if is_instance_valid($Gate):
		$Gate.queue_free()
		$RockBreakSFX.play()


func _on_minotaur_death():
	$MinotaurGateTimer.start()
