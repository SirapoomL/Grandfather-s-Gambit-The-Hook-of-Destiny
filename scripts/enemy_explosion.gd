extends CPUParticles2D

var smoke = true

# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true
	if smoke == true:
		$Smoke.play("default")
	else:
		$Smoke.visible = false
		$DeathSound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not emitting:
		queue_free()
