@tool
extends Node

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func rand_rot() -> float:
	return (PI/2.0) * rng.randi_range(0,4)

func rand_rot_vec3() -> Vector3:
	return Vector3(rand_rot(),rand_rot(),rand_rot())

func create_test_scene() -> void:
	var p : CubicVoxel = get_parent()
	if p != null:
		
		p.blocks_estates_set(Vector3.ZERO,BlockEstate.new(0))
		
		p.blocks_estates_set(Vector3(10,.0,.0),BlockEstate.new(2,Vector3i(0,0,0)))
		p.blocks_estates_set(Vector3(11,.0,.0),BlockEstate.new(2,Vector3(0,0,-1)))
		p.blocks_estates_set(Vector3(11,1,.0),BlockEstate.new(2,Vector3(0,0,-2)))
		p.blocks_estates_set(Vector3(10,1,.0),BlockEstate.new(2,Vector3(0,0,-3)))
		
		for i : int in range(0,4):
			p.blocks_estates_set(Vector3(2+i,.0,.0),BlockEstate.new(1,rand_rot_vec3()))
		
		for x : int in range(2,8):
			for y : int in range(2,50):
				for z : int in range(2,8):
					p.blocks_estates_set(Vector3(x,y,z),BlockEstate.new(0,rand_rot_vec3()))
		
		for x : int in range(2,8):
			for y : int in range(2,50):
				p.blocks_estates_set(Vector3(x,y,8),BlockEstate.new(3,rand_rot_vec3()))
			
		for x : int in range(2,8):
			for y : int in range(2,50):
				p.blocks_estates_set(Vector3(x,y,9),BlockEstate.new(4,rand_rot_vec3()))
		

func clean_build() -> void:
	var p : CubicVoxel = get_parent()
	if p != null:
		p.blocks_estates_clear()

func save_build() -> void:
	var p : CubicVoxel = get_parent()
	if p != null:
		p.blocks_estates_save("user://test.bin")

func load_build() -> void:
	var p : CubicVoxel = get_parent()
	if p != null:
		p.blocks_estates_load("user://test.bin")

@export_tool_button("build") var build = create_test_scene
@export_tool_button("clean") var clean = clean_build

@export_tool_button("save") var save = save_build
@export_tool_button("load") var load = load_build

func _ready() -> void:
	if not Engine.is_editor_hint():
		create_test_scene()
