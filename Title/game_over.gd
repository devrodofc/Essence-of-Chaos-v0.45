extends MarginContainer

@onready var restart_button: TextureButton = %Restart

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Title/title_screen.tscn")
