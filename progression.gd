extends Node

# Game State
var data_packets: int = 0
var multiplier: int = 1
var current_multiplier: float = 1.0
var upgrade_cost: int = 500

# Hardware State
var current_cpu: float = 0.0
var current_mem: float = 0.0
var current_rate: float = 0.0
var cpu_cores: int = 1
var cpu_threads: int = 1

var cpu_history: Array = []
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
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _has_tech(tech_name: GameEnums.Tech):
	var state = tech_unlocked_list[tech_name]
	return state
	
func _unlock_tech(tech_name: GameEnums.Tech):
	if _has_tech(tech_name):
		tech_unlocked.emit(tech_name)
	else:
		tech_unlocked_list[tech_name] = true
		tech_unlocked.emit(tech_name)
	
