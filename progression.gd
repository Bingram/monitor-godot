extends Node

# Game State
var data_packets: int = 0
var multiplier: int = 1
var current_multiplier: float = 1.0
var upgrade_cost: int = 500
var game_loaded: bool = false


var current_scene = null


# Hardware State
var current_cpu: float = 0.0
var current_mem: float = 0.0
var current_rate: float = 0.0
var cpu_cores: int = 1
var cpu_threads: int = 1

var cpu_history: Array = []
var cpu_graphs: Array = []
const MAX_HISTORY = 60

var tech_unlocked_list = {
	GameEnums.Tech.CPU_CORES: false,
	GameEnums.Tech.THREADS: false,
	GameEnums.Tech.CPU: true,
	GameEnums.Tech.CPU_FREQ: false,
	GameEnums.Tech.RAM: true,
	GameEnums.Tech.RAM_STATS: false,
	GameEnums.Tech.NET: false,
	GameEnums.Tech.NET_STATS: false,
	GameEnums.Tech.DISK: false,
	GameEnums.Tech.GPU: false,
	GameEnums.Tech.TEMPS: false
}

signal tech_unlocked(tech_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	_deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
	
func _has_tech(tech_name: GameEnums.Tech):
	var state = tech_unlocked_list[tech_name]
	return state
	
func _unlock_tech(tech_name: GameEnums.Tech):
	if _has_tech(tech_name):
		tech_unlocked.emit(tech_name)
	else:
		tech_unlocked_list[tech_name] = true
		tech_unlocked.emit(tech_name)
	
