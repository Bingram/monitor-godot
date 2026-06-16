extends Node

var points: int = 1
var has_cpu_cores: bool = false
var has_threads: bool = false
var has_ram: bool = false

signal tech_unlocked(tech_name)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _has_tech(tech_name: String):
	pass
	#need lookup logic for has a tech unlocked so we can have single CRUD methods
	
func _unlock_tech(tech_name: String):
	#need a better system for this
	#enum is the first idea, lots of repeated stuff here, could just have it pull a file
	#Add to the file as we go along and never touch this logic again
	
	#logic to handle the the unlock
	if tech_name == "cores":
		has_cpu_cores = true
		tech_unlocked.emit("cores")
	if tech_name == "threads":
		has_threads = true
		tech_unlocked.emit("threads")
	if tech_name == "ram":
		has_ram = true
		tech_unlocked.emit("ram")
