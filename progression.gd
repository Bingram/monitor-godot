extends Node

var points: int = 1
var has_cpu_cores: bool = false
var has_threads: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

signal tech_unlocked(tech_name)

func unlock_tech(tech_name: String):
	#logic to handle the the unlock
	if tech_name == "cores":
		has_cpu_cores = true
		tech_unlocked.emit("cores")
	if tech_name == "threads":
		has_threads = true
		tech_unlocked.emit("threads")
