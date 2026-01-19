extends Resource
class_name BlockData

@export var planes : Dictionary[PlaneInfo.BlockOrientation,Material] = {
	PlaneInfo.BlockOrientation.UP: null,
	PlaneInfo.BlockOrientation.DOWN: null,
	PlaneInfo.BlockOrientation.LEFT: null,
	PlaneInfo.BlockOrientation.RIGHT: null,
	PlaneInfo.BlockOrientation.FORWARD: null,
	PlaneInfo.BlockOrientation.BACK: null,
}
@export var model : PackedScene
