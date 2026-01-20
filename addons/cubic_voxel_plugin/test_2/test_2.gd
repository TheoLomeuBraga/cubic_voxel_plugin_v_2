extends Node3D

var rng : RandomNumberGenerator = RandomNumberGenerator.new()

func rand_rot() -> float:
	return (PI/2.0) * rng.randi_range(0,4)

func rand_rot_vec3() -> Vector3:
	return Vector3(rand_rot(),rand_rot(),rand_rot())


@export var chunck_size : Vector3i = Vector3i(16,16,16)
@export var chunck_count : Vector3i = Vector3i(8,1,8)


@export var blocks_data : Array[BlockData]
var blocks_data_mutex : Mutex = Mutex.new()

var chuncks : Array[CubicVoxel]

@export var noise : Noise

func build_chunck(idx:int) -> void:
	
	var mesh_instance : MeshInstance3D = MeshInstance3D.new()
	
	var chunck : CubicVoxel = CubicVoxel.new()
	chunck.blocks_data = blocks_data
	chunck.mesh_target = mesh_instance
	
	
	
	var cunck_position : Vector3 = Vector3(idx % chunck_count.x,.0,floor(idx/chunck_count.x)) * Vector3(chunck_size)
	
	for x : int in range(cunck_position.x,cunck_position.x+chunck_size.x):
		for y : int in range(cunck_position.y,cunck_position.y+chunck_size.y):
			for z : int in range(cunck_position.z,cunck_position.z+chunck_size.z):
				if noise != null:
					if noise.get_noise_2d(x,z) * chunck_size.y  > y:
						chunck.blocks_estates_set(Vector3(x,y,z),BlockEstate.new(0,rand_rot_vec3()))
					elif y == 0:
						chunck.blocks_estates_set(Vector3(x,y,z),BlockEstate.new(1,rand_rot_vec3()))
				else:
					chunck.blocks_estates_set(Vector3(x,y,z),BlockEstate.new(0,rand_rot_vec3()))
	
	call_deferred("add_child",chunck)
	chunck.call_deferred("set_owner",self)
	
	chunck.call_deferred("add_child",mesh_instance)
	mesh_instance.call_deferred("set_owner",self)
	
	
	
	blocks_data_mutex.lock()
	chuncks.push_back(chunck)
	blocks_data_mutex.unlock()
	
	print("chunck: ",idx," done")

var task_id : int = -1
func build_world() -> void:
	if task_id == -1:
		task_id = WorkerThreadPool.add_group_task(build_chunck, chunck_count.x*chunck_count.z)
		if Engine.is_editor_hint():
			WorkerThreadPool.wait_for_group_task_completion(task_id)
			task_id = -1

func _ready() -> void:
	build_world()
		
