@icon("res://addons/cubic_voxel_plugin/icon.svg")
@tool
extends Node
class_name CubicVoxel

# TODO: save and load

@export var blocks_data : Array[BlockData]

@export var mesh_target : MeshInstance3D
@export var collision_shape_target : CollisionShape3D

var blocks_estates_changed : bool = false
var blocks_estates : Dictionary[Vector3i,BlockEstate] = {}

func blocks_estates_set(pos:Vector3i,estate:BlockEstate) -> void:
	blocks_estates.set(pos,estate)
	blocks_estates_changed = true

func blocks_estates_has(pos:Vector3i) -> bool:
	return blocks_estates.has(pos)

func blocks_estates_get(pos:Vector3i) -> BlockEstate:
	return blocks_estates[pos]

func blocks_estates_erase(pos:Vector3i) -> void:
	blocks_estates.erase(pos)
	blocks_estates_changed = true

func blocks_estates_clear() -> void:
	blocks_estates.clear()
	blocks_estates_changed = true

func blocks_estates_save(path : String) -> void:
	var save_file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	save_file.store_var(blocks_estates,true)
	save_file.close()

func blocks_estates_load(path : String) -> void:
	if not FileAccess.file_exists(path):
		printerr("cant load voxel data on: ",path)
		return
	
	var save_file : FileAccess = FileAccess.open(path, FileAccess.READ)
	var data : Dictionary[Vector3i, Resource] = save_file.get_var(true)
	for pos : Vector3i in data:
		if data[pos] is BlockEstate:
			blocks_estates_set(pos,data[pos])
	
	
	save_file.close()


var planes_to_generate : Dictionary[Material,Array] #Dictionary[Material,Array[PlaneInfo]]
func add_planes_to_generate(mat:Material,plane:PlaneInfo) -> void:
	if not planes_to_generate.has(mat):
		planes_to_generate.set(mat,[])
	
	planes_to_generate[mat].push_back(plane)

func generate_planes() -> void:
	
	for pos : Vector3i in blocks_estates:
		var block_estate : BlockEstate = blocks_estates[pos]
		var block_data : BlockData = blocks_data[block_estate.id]
		
		for bo : PlaneInfo.BlockOrientation in block_data.planes:
			var mat : Material = block_data.planes[bo]
			var p : PlaneInfo = PlaneInfo.new(pos,block_estate.rotation,mat,bo)
			
			var side_block_position : Vector3 = p.position + Vector3i(p.get_normal())
			var has_empty_on_side : bool = not blocks_estates_has(side_block_position)
			var has_transparent_on_side : bool = not has_empty_on_side and blocks_data[blocks_estates_get(side_block_position).id].is_tarnsparent
			var has_diferent_block_type_on_side : bool = false
			if not has_empty_on_side:
				has_diferent_block_type_on_side = block_estate.id != blocks_estates_get(side_block_position).id
			
			if has_empty_on_side or (has_transparent_on_side and has_diferent_block_type_on_side):
				add_planes_to_generate(mat,p)
			

func generate_mesh() -> void:
	generate_planes()
	
	var mesh : ArrayMesh = ArrayMesh.new()
	var st : SurfaceTool = SurfaceTool.new()
	
	for m : Material in planes_to_generate:
		
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		for p : PlaneInfo in planes_to_generate[m]:
			
			var vertex : Array[Vector3] = p.get_vertex_data()
			var uv : Array[Vector2] = p.get_uv_data()
			
			for i : int in range(0,6):
				st.set_uv(uv[i])
				st.set_normal(p.get_normal())
				st.add_vertex(vertex[i])
		
		
		st.set_material(m)
		st.index()
		st.commit(mesh)
	
	planes_to_generate.clear()
	
	if mesh_target != null:
		mesh_target.call_deferred("set_mesh",mesh)
	
	var cps : ConcavePolygonShape3D = mesh.create_trimesh_shape()
	if collision_shape_target != null:
		collision_shape_target.call_deferred("set_shape",cps)
	
	blocks_estates_changed = false
	

var task_id : int = -1
var process_cubes = func(idx:int):
	generate_mesh()

func _process(delta: float) -> void:
	if blocks_estates_changed and task_id == -1:
		task_id = WorkerThreadPool.add_group_task(process_cubes, 1)
	
	if task_id != -1 and WorkerThreadPool.is_group_task_completed(task_id):
		task_id = -1
		
