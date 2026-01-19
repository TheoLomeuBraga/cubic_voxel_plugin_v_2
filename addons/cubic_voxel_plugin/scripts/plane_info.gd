@icon("res://addons/cubic_voxel_plugin/icon.svg")
extends Resource
class_name PlaneInfo

enum BlockOrientation {UP,DOWN,LEFT,RIGHT,FORWARD,BACK}
@export var orientation : BlockOrientation = BlockOrientation.UP
@export var material : Material
@export var position : Vector3i
@export var rotation : Vector3

var uv : Array[Vector2]
var vertex : Array[Vector3]

var plane_up : Array[Vector3] = [
	Vector3(-.5,.5, .5),
	Vector3(-.5,.5, -.5),
	Vector3(.5,.5, .5),
	
	Vector3(.5,.5, .5),
	Vector3(-.5,.5, -.5),
	Vector3(.5,.5, -.5),
]

var plane_down : Array[Vector3] = [
	Vector3(-.5,-.5, .5),
	Vector3(.5,-.5, .5),
	Vector3(-.5,-.5, -.5),
	
	Vector3(.5,-.5, .5),
	Vector3(.5,-.5, -.5),
	Vector3(-.5,-.5, -.5),
]

var plane_back : Array[Vector3] = [
	Vector3(-.5, .5,.5),
	Vector3(.5, .5,.5),
	Vector3(-.5, -.5,.5),
	
	Vector3(.5, .5,.5),
	Vector3(.5, -.5,.5),
	Vector3(-.5, -.5,.5),
]

var plane_forward : Array[Vector3] = [
	Vector3(-.5, .5,-.5),
	Vector3(-.5, -.5,-.5),
	Vector3(.5, .5,-.5),
	
	Vector3(.5, .5,-.5),
	Vector3(-.5, -.5,-.5),
	Vector3(.5, -.5,-.5),
]

var plane_right : Array[Vector3] = [
	Vector3(.5,-.5, .5),
	Vector3(.5,.5, .5),
	Vector3(.5,-.5, -.5),
	
	Vector3(.5,.5, .5),
	Vector3(.5,.5, -.5),
	Vector3(.5,-.5, -.5),
]

var plane_left : Array[Vector3] = [
	Vector3(-.5, .5,-.5),
	Vector3(-.5, .5,.5),
	Vector3(-.5, -.5,-.5),
	
	Vector3(-.5, .5,.5),
	Vector3(-.5, -.5,.5),
	Vector3(-.5, -.5,-.5),
]

#enum BlockOrientation {UP,DOWN,LEFT,RIGHT,FORWARD,BACK}
var orientation_to_normal : Dictionary[BlockOrientation,Vector3] = {
	BlockOrientation.UP: Vector3.UP,
	BlockOrientation.DOWN: Vector3.DOWN,
	BlockOrientation.LEFT: Vector3.LEFT,
	BlockOrientation.RIGHT: Vector3.RIGHT,
	BlockOrientation.FORWARD: Vector3.FORWARD,
	BlockOrientation.BACK: Vector3.BACK,
}

var orientation_to_plane : Dictionary[BlockOrientation,Array] = {
	BlockOrientation.UP: plane_up,
	BlockOrientation.DOWN: plane_down,
	BlockOrientation.LEFT: plane_left,
	BlockOrientation.RIGHT: plane_right,
	BlockOrientation.FORWARD: plane_forward,
	BlockOrientation.BACK: plane_back,
}

func _init(_position : Vector3i,_rotation : Vector3,_material : Material,_orientation : BlockOrientation = BlockOrientation.UP) -> void:
	position = _position
	rotation = _rotation
	material = _material
	orientation = _orientation

func remove_axis_from_vec3(input:Vector3,axis : int) -> Vector2:
	var ret : Vector2
	match axis:
		0:
			ret = Vector2(input.z,-input.y)
		1:
			ret = Vector2(input.x,input.z)
		2:
			ret = Vector2(input.x,-input.y)
	return ret

func get_uv_data() -> Array[Vector2]:
	var ret : Array[Vector2]
	for v : Vector3 in orientation_to_plane[orientation]:
		var axis_to_remove : int = 0
		
		if orientation == BlockOrientation.LEFT or orientation == BlockOrientation.RIGHT:
			axis_to_remove = 0
		elif orientation == BlockOrientation.UP or orientation == BlockOrientation.DOWN:
			axis_to_remove = 1
		elif orientation == BlockOrientation.FORWARD or orientation == BlockOrientation.BACK:
			axis_to_remove = 2
		
		ret.push_back(remove_axis_from_vec3(v,axis_to_remove) + Vector2(.5,.5))
	return ret

func rotate_vector3(input:Vector3,rotation:Vector3) -> Vector3:
	var ret : Vector3 = input
	ret = ret.rotated(Vector3.RIGHT,rotation.x)
	ret = ret.rotated(Vector3.UP,rotation.y)
	ret = ret.rotated(Vector3.FORWARD,rotation.z)
	return ret

func get_normal() -> Vector3:
	return rotate_vector3(orientation_to_normal[orientation],rotation)

func get_vertex_data() -> Array[Vector3]:
	var ret : Array[Vector3]
	for v : Vector3 in orientation_to_plane[orientation]:
		ret.push_back(rotate_vector3(v,rotation) + Vector3(position))
	return ret
