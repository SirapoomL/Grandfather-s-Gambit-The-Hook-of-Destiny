extends Area2D
class_name GorillaRoomEvent

signal gorilla_room_entered

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	



func _on_area_entered(area):
	if area.has_meta("player"):
		gorilla_room_entered.emit()
