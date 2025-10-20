extends MarginContainer


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/level2.tscn")
