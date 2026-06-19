extends RigidBody3D

@export var Speed = 60
@export var ID = 0

func _enter_tree() -> void:
	print(ID)
	print(multiplayer.get_unique_id())
	set_multiplayer_authority(ID)
	print("Multiplayer Authority given to ",get_multiplayer_authority())

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	var Dir = Vector3.ZERO
	if Input.is_action_pressed("Forward"):
		Dir += Vector3(0,0,-1)
	if Input.is_action_pressed("Backward"):
		Dir += Vector3(0,0,1)
	if Input.is_action_pressed("Left"):
		Dir += Vector3(-1,0,0)
	if Input.is_action_pressed("Right"):
		Dir += Vector3(1,0,0)
	if Input.is_action_just_pressed("ui_down"):
		Dir *= 100
	
	apply_central_force(Dir * Speed * delta)
	
