extends Area2D
class_name CameraOverrideArea

@export var set_default = false

@export var set_zoom = false
@export var zoom = Vector2(1, 1)

@export var set_offset = false
@export var offset = Vector2(0, 0)
@export var offset_facing_sensitive = false
var original_offset = Vector2(0, 0)

@export var set_anchor_mode = false
@export var anchor_mode = 1

@export var set_camera_pos = false
@export var target_camera_pos = Vector2.ZERO

@export var set_position_smoothing = false
@export var position_smoothing_enabled = true
@export var position_smoothing_speed = 5

@export var set_camera_limit = false
@export var camera_limit = Vector4(0, -100000000, 100000000, 100000000)

@export var transition_speed = 4.0

@export var switch_camera = false
@export var camera: Camera2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	original_offset = offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	



func _on_area_entered(area):
	if area.has_meta("player"):
		if offset_facing_sensitive and is_instance_valid(get_node("CollisionShape2D")):
			if get_node("CollisionShape2D").global_position.x < area.global_position.x:
				offset.x = -offset.x
				

		


func _on_area_exited(area):
	if area.has_meta("player"):
		if offset_facing_sensitive:
			offset = original_offset
