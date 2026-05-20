extends Area2D
var tile_size = 16
var move_delay = 0.025
var time_since_move = 0.0
var frozen = false

func _ready() -> void:
	monitoring = true
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if frozen:
		return
	time_since_move += delta
	if time_since_move >= move_delay:
		position.y -= tile_size
		time_since_move = 0.0

		if not monitoring:
			monitoring = true

func _on_area_entered(area: Area2D) -> void:
	if not frozen:
		if area.is_in_group("Blocks") or area.is_in_group("Barriers"):
			frozen = true
			snap_to_grid()

func _on_body_entered(body: Node) -> void:
	if not frozen:
		if body.is_in_group("Blocks") or body.is_in_group("Barriers"):
			frozen = true
			snap_to_grid()

func snap_to_grid() -> void:
	var pos = global_position + Vector2(8, 8)
	pos.x = round(pos.x / tile_size) * tile_size
	pos.y = round(pos.y / tile_size) * tile_size
	global_position = pos - Vector2(8, 8)
	add_to_group("Blocks") 
	get_tree().get_first_node_in_group("Main").check_rows()


		
