extends CheckBox

func _ready() -> void:
	var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
	if file:
		var is_fullscreen = file.get_var()
		file.close()
		button_pressed = is_fullscreen
		if is_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1152, 648))

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 648))
	
	var file = FileAccess.open("user://settings.cfg", FileAccess.WRITE)
	file.store_var(toggled_on)
	file.close()
