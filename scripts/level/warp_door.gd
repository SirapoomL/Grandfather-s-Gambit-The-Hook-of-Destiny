extends Node2D
class_name WarpDoor

@export var dest: WarpDoor = null
@export var label_text = "press e to enter"

var incoming_player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$InteractArea.get_node("Label").text = label_text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func prepare_player_enter(player):
	$InteractArea.on_cd = true
	incoming_player = player
	$Timer.start()

func _on_interact_area_player_warp(player):
	if is_instance_valid(dest):
		dest.prepare_player_enter(player)
		player.force_disable_cam_smoothing(true)
		player.global_position = dest.global_position
		player.velocity = Vector2.ZERO
	
	


func _on_interact_area_player_exit():
	if incoming_player != null:
		incoming_player.force_disable_cam_smoothing(false)
		incoming_player = null
