extends Node

var camera_override_area: CameraOverrideArea = null
@export var default_offset = Vector2.ZERO
@export var default_zoom = Vector2(1, 1)
@export var default_camera_limit = Vector4(0, -100000000, 100000000, 100000000)
@export var transition_speed = 4.0

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
	if camera_override_area:
		var coa = camera_override_area
		if coa.switch_camera:
			if is_instance_valid(coa.camera) and !coa.camera.is_current():
				coa.camera.make_current()
			return
		if coa.set_zoom:
			camera.zoom = camera.zoom.lerp(coa.zoom, delta * coa.transition_speed)
		if coa.set_offset:
			camera.offset = camera.offset.lerp(coa.offset, delta * coa.transition_speed)
		if coa.set_anchor_mode:
			camera.anchor_mode = coa.anchor_mode
		if coa.set_camera_pos:
			camera.global_position = camera.global_position.lerp(coa.target_camera_pos, delta * coa.transition_speed)
			camera.position_smoothing_enabled = false
		#if coa.set_camera_limit:
			#camera.limit_left = coa.camera_limit.x
			#camera.limit_top = coa.camera_limit.y
			#camera.limit_right = coa.camera_limit.z
			#camera.limit_bottom = coa.camera_limit.w 			
	else:
		camera.enabled = true
		camera.position_smoothing_enabled = true
		camera.anchor_mode = 1
		camera.zoom = camera.zoom.lerp(default_zoom, delta * transition_speed)
		camera.offset = camera.offset.lerp(default_offset, delta * transition_speed)
		camera.make_current()
		#camera.limit_left = default_camera_limit.x
		#camera.limit_top = default_camera_limit.y
		#camera.limit_right = default_camera_limit.z
		#camera.limit_bottom = default_camera_limit.w
		
func set_camera_override_area(coa: CameraOverrideArea):
	camera_override_area = coa
	
func remove_camera_override_area():
	camera_override_area = null


