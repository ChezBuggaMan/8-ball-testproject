class_name Entity
extends Node3D

@export var EntityModel: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Super Class Ready")
	#self.add_child(scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
