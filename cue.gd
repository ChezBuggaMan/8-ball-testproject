extends MeshInstance3D

#How far forward
@export var MaxDistanceForward = 1
@export var MaxDistanceBack = -3
@export var CurDistance = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _input(event):
	#if event is InputEventMouseMotion:
		#print(event.relative)
		#if event.relative.x > 1:
			#print("Right!")
