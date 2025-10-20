extends Node2D

func _on_exit_sensor_area_entered(_area: Area2D) -> void:
	get_tree().change_scene_to_file("res://Title/FimDaDemo.tscn")
