extends Node

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func rand_rot() -> float:
	return (PI/2.0) * rng.randi_range(0,4)

func _ready() -> void:
	var p : CubicVoxel = get_parent()
	if p != null:
		
		p.blocks_estates_set(Vector3.ZERO,BlockEstate.new(0))
		
		for i : int in range(0,4):
			p.blocks_estates_set(Vector3(2+i,.0,.0),BlockEstate.new(1,Vector3(.0,(PI/2) * i,.0)))
		
		for x : int in range(2,8):
			for y : int in range(2,8):
				for z : int in range(2,8):
					p.blocks_estates_set(Vector3(x,y,z),BlockEstate.new(0,Vector3(rand_rot(),rand_rot(),rand_rot())))
		
		p.generate_mesh()
