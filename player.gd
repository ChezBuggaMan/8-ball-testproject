extends CharacterBody3D

@export var Speed = 30

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var Dir = Vector3.ZERO
	if Input.is_action_pressed("Forward"):
		Dir += Vector3(1,0,0)
	
	velocity = Dir * Speed * delta
	
	move_and_slide()
