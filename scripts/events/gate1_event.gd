extends InteractEvent
class_name Gate1Event

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func interact(player: Player):
	if !GameState.gate_1_opened and GameState.minotaur_dead:
		$Text.hide()
		if is_instance_valid($Gate):
			$Gate.queue_free()
		GameState.gate_1_opened = true
		$RockBreakSFX.play()
		
			

	


func _on_area_entered(area):
	if area.has_meta("player"):
		if !GameState.gate_1_opened:
			if GameState.minotaur_dead:
				$Text.text = "press e to use minotaur's soul"
			else:
				$Text.text = "required minotaur's soul"
			$Text.show()




func _on_area_exited(area):
	if area.has_meta("player"):
		$Text.hide()
