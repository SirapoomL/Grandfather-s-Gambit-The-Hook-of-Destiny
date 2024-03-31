extends Node

var camera_override_area: CameraOverrideArea = null
@export var default_offset = Vector2.ZERO
@export var default_zoom = Vector2(1, 1)

var t = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func process(camera: Camera2D, delta):
	if not is_instance_valid(camera):
		return
	t += delta
	if camera_override_area:
		var coa = camera_override_area
		if coa.set_zoom:
			camera.zoom = coa.zoom
		if coa.set_offset:
			camera.offset.lerp(coa.offset, t)
		if coa.set_anchor_mode:
			camera.anchor_mode = coa.anchor_mode
		if coa.set_camera_pos:
			camera.global_position.lerp(coa.target_camera_pos, t)
	else:
		camera.enabled = true
		camera.anchor_mode = 1
		camera.zoom = default_zoom
		camera.offset = default_offset
		
func set_camera_override_area(coa: CameraOverrideArea):
	camera_override_area = coa
	
func remove_camera_override_area():
	camera_override_area = null

