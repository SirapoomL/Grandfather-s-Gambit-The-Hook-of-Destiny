extends Area2D
class_name XPGem

@export var exp = 20

var collected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	if area.has_meta("player") and !collected:
		collected = true
		area.get_parent().gain_exp(exp)
		$CollectSFX.play()
		hide()


func _on_collect_sfx_finished():
	queue_free()
