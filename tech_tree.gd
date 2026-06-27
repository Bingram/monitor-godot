extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _return():
	# Return to game window
	Progression.goto_scene("res://game_screen.tscn")

func _on_button_pressed(tech_name: String):
	var tech_enum = GameEnums.Tech[tech_name]
	if not Progression._has_tech(tech_enum):
		Progression._unlock_tech(tech_enum)
