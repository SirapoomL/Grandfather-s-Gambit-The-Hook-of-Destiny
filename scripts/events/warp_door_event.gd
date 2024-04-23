extends InteractEvent
class_name WarpDoorEvent

var on_cd = false

signal player_warp(player: Player)
signal player_exit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func interact(player: Player):
	if not on_cd:
		player_warp.emit(player)


func _on_timer_timeout():
	on_cd = false

		


func _on_area_exited(area):
	if area.has_meta("player"):
		player_exit.emit()
		$Label.hide()


func _on_area_entered(area):
	if area.has_meta("player"):
		$Label.show()
