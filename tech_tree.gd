extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _retrun():
	# Return to game window
	get_tree().change_scene_to_file("res://game_screen.tscn")
	
func _on_cores_button_pressed():
	# Call Autoload directly
	if not Progression.has_cpu_cores:
		Progression.unlock_tech("cores")

func _on_threads_button_pressed():
	# Call Autoload directly
	if not Progression.has_threads:
		Progression.unlock_tech("threads")
