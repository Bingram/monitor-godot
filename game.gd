extends Control

const SAVE_PATH = "user://idle_miner_save.json"

## Game State
#var data_packets: int = 0
#var multiplier: int = 1
#var current_multiplier: float = 1.0
#var upgrade_cost: int = 500
#
## Hardware State
#var current_cpu: float = 0.0
#var current_mem: float = 0.0
#var current_rate: float = 0.0
#var cpu_cores: int = 1
#var cpu_threads: int = 1
#
#var cpu_history: Array = []
#const MAX_HISTORY = 60
#var loaded: bool = false

# UI Node References
@onready var cpu_label = $GameWindow/System/CPULabel
@onready var cpu_graph = $GameWindow/Graph/GraphBG/CPUGraph
@onready var graph_bg = $GameWindow/Graph/GraphBG
@onready var mem_label = $GameWindow/System/Memory
@onready var mem_bar = $GameWindow/Graph/MemBar
@onready var score_label = $GameWindow/System/GamePanel/GameBox/ScoreLabel
@onready var rate_label = $GameWindow/System/GamePanel/GameBox/RateLabel
@onready var upgrade_btn = $GameWindow/System/GamePanel/GameBox/UpgradeButton
@onready var tick_timer = $TickTimer
@onready var core_label = $GameWindow/System/Cores
@onready var threads_label = $GameWindow/System/Threads
@onready var ram_label = $GameWindow/System/Ram

# Godot uses "res://" to look in the root folder of the project
const STATS_FILE = "res://hardware_stats.json"

func _ready():
	# 1. Initialize history array with 0s unless populated
	if Progression.cpu_history.is_empty():
		for i in range(Progression.MAX_HISTORY):
			Progression.cpu_history.append(0.0)
		
	# 2. Connect signals (Replaces Tkinter button commands and loops)
	tick_timer.timeout.connect(_on_tick)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	
	# 3. Load Save Data
	if not Progression.game_loaded:
		load_game()
	else:
		update_rate()
	update_ui()

func _on_tick():
	_read_hardware_stats()
	
	# --- Game Logic ---
	var earned_this_tick = get_rate()
	Progression.data_packets += earned_this_tick
	
	# --- Graph History ---
	Progression.cpu_history.pop_front()
	Progression.cpu_history.append(Progression.current_cpu)
	
	# Update score rate
	update_rate()
	update_ui()

func update_ui():
	# Update Labels
	cpu_label.text = "CPU Usage: %d%%" % Progression.current_cpu
	mem_label.text = "Memory Usage: %d%%" % Progression.current_mem
	mem_bar.value = Progression.current_mem
	
	update_rate()
	score_label.text = "Data Packets: " + str(Progression.data_packets)
	var rate = get_rate()
	rate_label.text = "Mining Rate: %d / sec (Multiplier: x%d)" % [rate, Progression.current_multiplier]
	
	# Update Button
	upgrade_btn.text = "Buy Overclock (Cost: %d)" % Progression.upgrade_cost
	upgrade_btn.disabled = Progression.data_packets < Progression.upgrade_cost
	
	if Progression._has_tech(GameEnums.Tech.CPU_CORES):
		core_label.text = "Cores: %d" % Progression.cpu_cores
	if Progression._has_tech(GameEnums.Tech.THREADS):
		threads_label.text = "Threads: %d" % Progression.cpu_threads
	if Progression._has_tech(GameEnums.Tech.RAM):
		ram_label.text = "Ram: %s" % Progression._has_tech(GameEnums.Tech.RAM) 
	
	draw_graph()

func draw_graph():
	# Clear the old line
	cpu_graph.clear_points()
	
	var width = graph_bg.custom_minimum_size.x
	var height = graph_bg.custom_minimum_size.y
	var step_x = width / float(Progression.MAX_HISTORY - 1)
	
	# Rebuild the Line2D points based on the history array
	for i in range(Progression.cpu_history.size()):
		var x = i * step_x
		# Invert Y so 100% is at the top (0) and 0% is at the bottom (height)
		var y = height - (Progression.cpu_history[i] / 100.0 * height)
		cpu_graph.add_point(Vector2(x, y))

func get_rate():
	return Progression.current_rate
	
func update_rate():
	var cpu_cores = 1
	var cpu_threads = 1
	var current_cpu = Progression.current_cpu
	var current_mult = Progression.current_multiplier
	var current_mem = Progression.current_mem
	
	# Check unlocks
	if Progression._has_tech(GameEnums.Tech.CPU_CORES):
		cpu_cores = Progression.cpu_cores
	if Progression._has_tech(GameEnums.Tech.THREADS):
		cpu_threads = Progression.cpu_threads
					
	Progression.current_rate = int(
		current_cpu * (
			current_mult + 
			cpu_cores + 
			cpu_threads + 
			current_mem *
			.1
		)
	)
	
func get_multiplier():
	return Progression.current_multiplier
	
func update_multiplier(mult):
	Progression.current_multiplier = mult

func _on_upgrade_pressed():
	if Progression.data_packets >= Progression.upgrade_cost:
		Progression.data_packets -= Progression.upgrade_cost
		Progression.current_multiplier += 1
		Progression.upgrade_cost = int(Progression.upgrade_cost * 1.1)
		update_ui()

# ==========================================
# Save and Load System
# ==========================================
func save_game():
	var save_dict = {
		"data_packets": Progression.data_packets,
		"multiplier": Progression.current_multiplier,
		"upgrade_cost": Progression.upgrade_cost
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict, "\t"))

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		var json = JSON.new()
		if json.parse(content) == OK:
			if not Progression.game_loaded:
				var data = json.data
				Progression.data_packets = data.get("data_packets", 0)
				Progression.current_multiplier = data.get("multiplier", 1)
				Progression.upgrade_cost = data.get("upgrade_cost", 500)
				Progression.game_loaded = true
			
func _read_hardware_stats():
	# Check if Python has created the file yet
	if FileAccess.file_exists(STATS_FILE):
		# Open and read the raw text
		var file = FileAccess.open(STATS_FILE, FileAccess.READ)
		var content = file.get_as_text()
		file.close() # Always close the file to free up memory
		
		# Parse the text into a Godot Dictionary
		var json = JSON.new()
		#attempt to parse file content
		#if error returned, it won't load the data
		var error = json.parse(content)
		
		if error == OK:
			var data = json.data
			if data.has("cpu") and data.has("mem_percent"):
				# Apply the real data to the UI labels
				Progression.current_cpu = data["cpu"]
				Progression.current_mem = data["mem_percent"]
				Progression.cpu_cores = data["cores"]
				Progression.cpu_threads = data["threads"]
		else:
			prints("error encoutnerd")
			#dosomething

func _open_tech_tree():
	# Opens tech tree
	Progression.goto_scene("res://tech_tree.tscn")

func _return_to_game():
	# Return to game window
	Progression.goto_scene("res://game_screen.tscn")

# Triggers when the game window is closed
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
