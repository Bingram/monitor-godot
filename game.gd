extends Control

const SAVE_PATH = "user://idle_miner_save.json"

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

# UI Node References
@onready var cpu_label = $VBoxContainer/CPULabel
@onready var cpu_graph = $VBoxContainer/GraphBG/CPUGraph
@onready var graph_bg = $VBoxContainer/GraphBG
@onready var mem_label = $VBoxContainer/Memory
@onready var mem_bar = $VBoxContainer/MemBar
@onready var score_label = $VBoxContainer/GamePanel/GameBox/ScoreLabel
@onready var rate_label = $VBoxContainer/GamePanel/GameBox/RateLabel
@onready var upgrade_btn = $VBoxContainer/GamePanel/GameBox/UpgradeButton
@onready var tick_timer = $TickTimer
@onready var core_label = $VBoxContainer/Cores
@onready var threads_label = $VBoxContainer/Threads

# Godot uses "res://" to look in the root folder of the project
const STATS_FILE = "res://hardware_stats.json"

func _ready():
	# 1. Initialize history array with 0s
	for i in range(MAX_HISTORY):
		cpu_history.append(0.0)
		
	# 2. Connect signals (Replaces Tkinter button commands and loops)
	tick_timer.timeout.connect(_on_tick)
	upgrade_btn.pressed.connect(_on_upgrade_pressed)
	
	# 3. Load Save Data
	load_game()
	update_ui()

func _on_tick():
	_read_hardware_stats()
	
	# --- Game Logic ---
	var earned_this_tick = get_rate()
	data_packets += earned_this_tick
	
	# --- Graph History ---
	cpu_history.pop_front()
	cpu_history.append(current_cpu)
	
	# Update score rate
	update_rate(int(current_cpu * (current_multiplier + cpu_cores + cpu_threads + current_mem*.1)))
	
	update_ui()

func update_ui():
	# Update Labels
	cpu_label.text = "CPU Usage: %d%%" % current_cpu
	mem_label.text = "Memory Usage: %d%%" % current_mem
	mem_bar.value = current_mem
	
	score_label.text = "Data Packets: " + str(data_packets)
	var rate = get_rate()
	rate_label.text = "Mining Rate: %d / sec (Multiplier: x%d)" % [rate, current_multiplier]
	
	# Update Button
	upgrade_btn.text = "Buy Overclock (Cost: %d)" % upgrade_cost
	upgrade_btn.disabled = data_packets < upgrade_cost
	
	if Progression.has_cpu_cores:
		core_label.text = "Cores: %d" % cpu_cores
	if Progression.has_threads:
		threads_label.text = "Threads: %d" % cpu_threads
	
	draw_graph()

func draw_graph():
	# Clear the old line
	cpu_graph.clear_points()
	
	var width = graph_bg.custom_minimum_size.x
	var height = graph_bg.custom_minimum_size.y
	var step_x = width / float(MAX_HISTORY - 1)
	
	# Rebuild the Line2D points based on the history array
	for i in range(cpu_history.size()):
		var x = i * step_x
		# Invert Y so 100% is at the top (0) and 0% is at the bottom (height)
		var y = height - (cpu_history[i] / 100.0 * height)
		cpu_graph.add_point(Vector2(x, y))

func get_rate():
	return current_rate
	
func update_rate(rate):
	current_rate = rate
	
func get_multiplier():
	return current_multiplier
	
func update_multiplier(mult):
	current_multiplier = mult

func _on_upgrade_pressed():
	if data_packets >= upgrade_cost:
		data_packets -= upgrade_cost
		current_multiplier += 1
		upgrade_cost = int(upgrade_cost * 1.1)
		update_ui()

# ==========================================
# Save and Load System
# ==========================================
func save_game():
	var save_dict = {
		"data_packets": data_packets,
		"multiplier": current_multiplier,
		"upgrade_cost": upgrade_cost
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
			var data = json.data
			data_packets = data.get("data_packets", 0)
			current_multiplier = data.get("multiplier", 1)
			upgrade_cost = data.get("upgrade_cost", 500)
			
func _read_hardware_stats():
	# Check if Python has created the file yet
	if FileAccess.file_exists(STATS_FILE):
		# Open and read the raw text
		var file = FileAccess.open(STATS_FILE, FileAccess.READ)
		var content = file.get_as_text()
		file.close() # Always close the file to free up memory
		
		# Parse the text into a Godot Dictionary
		var json = JSON.new()
		var error = json.parse(content)
		
		if error == OK:
			var data = json.data
			if data.has("cpu") and data.has("mem"):
				# Apply the real data to the UI labels
				current_cpu = data["cpu"]
				current_mem = data["mem"]
				if Progression.has_cpu_cores:
					cpu_cores = data["cores"]
				if Progression.has_threads:
					cpu_threads = data["threads"]
				
				
				
func _open_tech_tree():
	# Opens tech tree
	get_tree().change_scene_to_file("res://tech_tree.tscn")

func _return_to_game():
	# Return to game window
	get_tree().change_scene_to_file("res://game_screen.tscn")

# Triggers when the game window is closed
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
