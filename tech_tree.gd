extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _return():
	# Return to game window
	get_tree().change_scene_to_file("res://game_screen.tscn")

# need a better way to unlock a tech on button press
# rather than a single function for each button

func _on_button_pressed(tech_name: String):
	if not Progression.has_tech(tech_name):
		Progression.unlock_tech(tech_name)
		
func _on_cores_button_pressed():
	# Call Autoload directly
	if not Progression.has_cpu_cores:
		Progression.unlock_tech("cores")

func _on_threads_button_pressed():
	# Call Autoload directly
	if not Progression.has_threads:
		Progression.unlock_tech("threads")
		
func _on_disk_button_pressed():
	if not Progression.has_disks:
		Progression.unlock_tech("disks")
