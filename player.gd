extends Node2D

var tile_size = 16


var block_scene = preload("res://block.tscn")

func _ready() -> void:
	add_to_group("Player")

func _process(delta: float):
	if Input.is_action_just_pressed("Left") and position.x >= -24 :
		$AudioStreamPlayer2D.play()
		position.x -= tile_size
	elif Input.is_action_just_pressed("Right") and position.x <= 104:
		$AudioStreamPlayer2D.play()
		position.x += tile_size
	
	if Input.is_action_just_pressed("escape"):
		SceneManager.change_scene("res://MainMenu.tscn")
			
	

	position = position.snapped(Vector2.ONE * tile_size)
	position.x = position.x - 8
	position.y = position.y - 8
	
	if Input.is_action_just_pressed("Shoot"):
		$AudioStreamPlayer2D2.play()
		var block = block_scene.instantiate()
		block.position = global_position
		get_parent().get_parent().get_parent().add_child(block)
