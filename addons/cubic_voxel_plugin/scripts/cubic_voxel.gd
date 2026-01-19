extends Node
class_name CubicVoxel

@export var blocks_data : Array[BlockData]

@export var mesh_target : MeshInstance3D

var blocks_estates : Dictionary[Vector3i,BlockEstate]

func blocks_estates_set(pos:Vector3i,estate:BlockEstate) -> void:
	blocks_estates.set(pos,estate)

func blocks_estates_has(pos:Vector3i) -> bool:
	return blocks_estates.has(pos)

func blocks_estates_get(pos:Vector3i) -> BlockEstate:
	return blocks_estates[pos]

func blocks_estates_erase(pos:Vector3i) -> void:
	blocks_estates.erase(pos)

var planes_to_generate : Dictionary[Material,Array] #Dictionary[Material,Array[PlaneInfo]]
func add_planes_to_generate(mat:Material,plane:PlaneInfo) -> void:
	if not planes_to_generate.has(mat):
		planes_to_generate.set(mat,[])
	
	planes_to_generate[mat].push_back(plane)

func generate_planes() -> void:
	
	planes_to_generate.clear()
	
	for pos : Vector3i in blocks_estates:
		var block_estate : BlockEstate = blocks_estates[pos]
		var block_data : BlockData = blocks_data[block_estate.id]
		
		if block_data.model != null:
			continue
		
		for bo : PlaneInfo.BlockOrientation in block_data.planes:
			var mat : Material = block_data.planes[bo]
			var p : PlaneInfo = PlaneInfo.new(pos,block_estate.rotation,mat,bo)
			
			#if not blocks_estates_has(p.position + Vector3i(p.get_normal())):
			#	add_planes_to_generate(mat,p)
			add_planes_to_generate(mat,p)
			

var vert_count : int = 0
var plane_count : int = 0
func generate_mesh() -> void:
	generate_planes()
	
	var mesh : ArrayMesh = ArrayMesh.new()
	var st : SurfaceTool = SurfaceTool.new()
	
	for m : Material in planes_to_generate:
		
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		
		for p : PlaneInfo in planes_to_generate[m]:
			
			plane_count+=1
			
			var vertex : Array[Vector3] = p.get_vertex_data()
			var uv : Array[Vector2] = p.get_uv_data()
			
			for i : int in range(0,6):
				st.set_uv(uv[i])
				st.set_normal(p.get_normal())
				st.add_vertex(vertex[i])
				vert_count += 1
		
		
		st.set_material(m)
		st.index()
		st.commit(mesh)
		
		print("vert_count: ",vert_count)
		print("plane_count: ",plane_count)

	
	if mesh_target != null:
		mesh_target.mesh = mesh
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
