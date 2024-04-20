extends Node2D
class_name CheckPoint


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_interact_area_area_entered(area):
	if area.has_meta("player"):
		$Tooltip.show()



func _on_interact_area_area_exited(area):
	if area.has_meta("player"):
		$Tooltip.hide()
