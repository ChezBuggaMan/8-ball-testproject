extends RigidBody3D

@export var Speed = 60
@export var ID = 0

func _enter_tree() -> void:
	set_multiplayer_authority(ID)
	print("Player ", ID, " authority set. My unique id is ", multiplayer.get_unique_id())

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

	apply_central_force(Dir * Speed * delta)
