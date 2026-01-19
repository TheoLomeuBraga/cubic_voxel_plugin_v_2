extends Node

var rng : RandomNumberGenerator = RandomNumberGenerator.new()


func rand_rot() -> float:
	return (PI/2.0) * rng.randi_range(0,4)

func rand_rot_vec3() -> Vector3:
	return Vector3(rand_rot(),rand_rot(),rand_rot())

func _ready() -> void:
	var p : CubicVoxel = get_parent()
	if p != null:
		
		p.blocks_estates_set(Vector3.ZERO,BlockEstate.new(0))
		
		p.blocks_estates_set(Vector3(10,.0,.0),BlockEstate.new(2,Vector3(.0,.0,.0)))
		p.blocks_estates_set(Vector3(11,.0,.0),BlockEstate.new(2,Vector3(.0,.0,-(PI/2.0)*1)))
		p.blocks_estates_set(Vector3(11,1,.0),BlockEstate.new(2,Vector3(.0,.0,-(PI/2.0)*2)))
		p.blocks_estates_set(Vector3(10,1,.0),BlockEstate.new(2,Vector3(.0,.0,-(PI/2.0)*3)))
		
		for i : int in range(0,4):
			p.blocks_estates_set(Vector3(2+i,.0,.0),BlockEstate.new(1,rand_rot_vec3()))
		
		for x : int in range(2,8):
			for y : int in range(2,100):
				for z : int in range(2,8):
					p.blocks_estates_set(Vector3(x,y,z),BlockEstate.new(0,rand_rot_vec3()))
		
		for x : int in range(2,8):
			for y : int in range(2,100):
				p.blocks_estates_set(Vector3(x,y,8),BlockEstate.new(3,rand_rot_vec3()))
			
		for x : int in range(2,8):
			for y : int in range(2,100):
				p.blocks_estates_set(Vector3(x,y,9),BlockEstate.new(4,rand_rot_vec3()))
		
