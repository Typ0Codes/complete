extends Node

signal scene_change_requested(path)

func _ready() -> void:
	if FileAccess.file_exists("user://settings.cfg"):
		var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
		var is_fullscreen = file.get_var()
		file.close()
		if is_fullscreen == true:
			call_deferred("apply_fullscreen")
		else:
			call_deferred("apply_windowed")

func apply_fullscreen() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func apply_windowed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1152, 648))

func change_scene(path: String) -> void:
	emit_signal("scene_change_requested", path)
