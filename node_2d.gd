extends Node2D

var tile_size = 16

var cols = 11

var points = 0

var point_gain = 100

var block_scene = preload("res://block.tscn")
var spawn_timer = 0.0
var spawn_delay = 2.0

var grid_start_x = -40  
var spawn_y = -280      

var game_over = false
var bottom_y = -8 

var increases = 0

var lines = 0

var level = 1

var highscore = 0

var highline = 0

func _ready() -> void:
	add_to_group("Main")
	var file = FileAccess.open("user://hiscore.cfg", FileAccess.READ)
	if file:
		highscore = file.get_var()
	
	var fileline = FileAccess.open("user://hiline.cfg", FileAccess.READ)
	if fileline:
		highline = fileline.get_var()

func push_blocks_down() -> void:
	var blocks = get_tree().get_nodes_in_group("Blocks")
	for block in blocks:
		block.global_position.y += tile_size

func check_game_over() -> void:
	var blocks = get_tree().get_nodes_in_group("Blocks")
	for block in blocks:
		if block.frozen and block.global_position.y >= bottom_y - tile_size:
			trigger_game_over()
			return

func _process(delta: float) -> void:
	if game_over:
		return
	spawn_timer += delta
	if spawn_timer >= spawn_delay:
		spawn_timer = 0.0
		push_blocks_down()
		spawn_row()
		check_game_over()  

func trigger_game_over() -> void:
	game_over = true
	print("game over! score: ", points)

	get_tree().get_nodes_in_group("Player")[0].set_process(false)
	$Ui/Gameover.visible = true
	$AudioStreamPlayer2D2.play()
	
	var file = FileAccess.open("user://hiscore.cfg", FileAccess.WRITE)
	if file:
		file.store_var(points)
		file.close()
	var fileline = FileAccess.open("user://hiline.cfg", FileAccess.WRITE)
	if fileline:
		fileline.store_var(lines)
		fileline.close()

func spawn_row() -> void:
	for col in range(cols):
		if randi() % 2 == 0:
			var block = block_scene.instantiate()
			block.frozen = true
			add_child(block)
			block.global_position = Vector2(grid_start_x + (col * tile_size), spawn_y)
			block.add_to_group("Blocks")  
	spawn_delay = max(0.75, spawn_delay - 0.001)
	point_gain += 10
	increases += 1
	if increases % 5 == 0:
		level += 1

func check_rows() -> void:
	var blocks = get_tree().get_nodes_in_group("Blocks")
	
	var rows = {}
	for block in blocks:
		var row_y = round(block.global_position.y)
		if not rows.has(row_y):
			rows[row_y] = []
		rows[row_y].append(block)
	
	for row_y in rows:
		if rows[row_y].size() == cols:
			points += point_gain
			print("clearing row at y: ", row_y)
			lines += 1
			$AudioStreamPlayer2D.play()
			for block in blocks:
				if not block in rows[row_y]:
					var block_y = round(block.global_position.y)
					if block_y > row_y: 
						block.global_position.y -= tile_size  
			
			for block in rows[row_y]:
				block.queue_free()
				
func _input(event: InputEvent) -> void:
	if game_over:
		if event.is_pressed():
			if not event.is_action("Left") and not event.is_action("Right") and not event.is_action("Shoot"):

				for block in get_tree().get_nodes_in_group("Blocks"):
					block.queue_free()
				SceneManager.change_scene("res://node_2d.tscn")
	
	
