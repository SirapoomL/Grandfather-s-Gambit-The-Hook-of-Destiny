extends Area2D
class_name CameraOverrideArea

@export var set_default = false

@export var set_zoom = false
@export var zoom = Vector2(1, 1)

@export var set_offset = false
@export var offset = Vector2(0, 0)

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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
