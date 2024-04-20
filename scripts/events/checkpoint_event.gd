extends InteractEvent
class_name CheckPointEvent

var on_cooldown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func interact(player: Player):
	if !on_cooldown:
		player.save(position)
		player.current_hp = player.max_hp
		$IgniteSFX.play()
		on_cooldown = true
		$CDTimer.start()
	



func _on_cd_timer_timeout():
	on_cooldown = false
