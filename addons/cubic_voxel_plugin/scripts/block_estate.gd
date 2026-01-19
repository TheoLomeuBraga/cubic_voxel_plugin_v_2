@icon("res://addons/cubic_voxel_plugin/icon.svg")
extends Resource
class_name BlockEstate

@export var id : int
@export var rotation : Vector3i

func _init(_id : int,_rotation : Vector3 = Vector3.ZERO) -> void:
	id = _id
	rotation = _rotation
