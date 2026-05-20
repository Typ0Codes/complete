extends Node3D
var menu_scene = preload("res://MainMenu.tscn")
var viewport : SubViewport
var loaded = false
var zooming_in = false
var zoomed_in = false
var zoom_speed = 3.0

@export var player_camera : Camera3D
@export var screen_camera_position : Node3D  
var original_camera_transform : Transform3D

func _ready() -> void:
	
	viewport = $CanvasLayer2/SubViewport
	viewport.handle_input_locally = false
	viewport.audio_listener_enable_2d = true  
	
	var instance = menu_scene.instantiate()
	viewport.add_child(instance)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	$MeshInstance3D.set_surface_override_material(0, mat)
	
	$Area3D.body_entered.connect(_on_area_entered)
	$Area3D.body_exited.connect(_on_area_exited)
	
	SceneManager.scene_change_requested.connect(_on_scene_change)
	
	var file = FileAccess.open("user://settings.cfg", FileAccess.READ)
	if file:
		var is_fullscreen = file.get_var()
		file.close()
		if is_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1152, 648))

	

	

func _on_scene_change(path: String) -> void:
	
	for child in viewport.get_children():
		child.queue_free()
	await get_tree().process_frame
	
	var instance = load(path).instantiate()
	viewport.add_child(instance)

func _on_area_entered(body: Node) -> void:
	if body is CharacterBody3D and not loaded:
		loaded = true

func _on_area_exited(body: Node) -> void:
	viewport.handle_input_locally = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	loaded = false
	zoomed_in = false

func _unhandled_input(event: InputEvent) -> void:
	if loaded and event.is_action_pressed("Interact") and not zoomed_in:
		original_camera_transform = player_camera.global_transform
		zooming_in = true
		zoomed_in = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().get_nodes_in_group("Player3d")[0].set_process(false)
		get_tree().get_nodes_in_group("Player3d")[0].set_physics_process(false)
		set_shader_zoom(true)
		return
	
	if zoomed_in and event.is_action_pressed("Interact"):
		zoomed_in = false
		zooming_in = false
		viewport.handle_input_locally = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player_camera.global_transform = original_camera_transform
		get_tree().get_nodes_in_group("Player3d")[0].set_process(true)
		get_tree().get_nodes_in_group("Player3d")[0].set_physics_process(true)
		set_shader_zoom(false)
		return
	
	if zoomed_in and not zooming_in:
		
		if event is InputEventMouseButton or event is InputEventMouseMotion:
			var camera = player_camera
			var mouse_pos = get_viewport().get_mouse_position()
			
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * 100.0
			
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(from, to)
			var result = space_state.intersect_ray(query)
			
			if result:
				var local_pos = $MeshInstance3D.to_local(result.position)
				var mesh_size = $MeshInstance3D.get_aabb().size
				var uv = Vector2(
					(local_pos.x / mesh_size.x + 0.5),
					(0.5 - local_pos.y / mesh_size.y)
				)
				var viewport_pos = uv * Vector2(viewport.size)
				var new_event = event.duplicate()
				new_event.position = viewport_pos
				viewport.push_input(new_event)
	
	
func set_shader_zoom(is_zoomed: bool) -> void:
	var mat = $CanvasLayer/ColorRect.material
	mat.set_shader_parameter("zoomed_in", is_zoomed)

func _process(delta: float) -> void:
	if zooming_in and player_camera and screen_camera_position:
		player_camera.global_transform = player_camera.global_transform.interpolate_with(
			screen_camera_position.global_transform, zoom_speed * delta
		)
		
		if player_camera.global_position.distance_to(screen_camera_position.global_position) < 0.05:
			zooming_in = false
			viewport.handle_input_locally = true
	 
	var screen_pos = player_camera.unproject_position($MeshInstance3D.global_position)
	var screen_size = get_viewport().get_visible_rect().size
	
	var uv_pos = screen_pos / screen_size
	
	
	var mat = $CanvasLayer/ColorRect.material
	mat.set_shader_parameter("monitor_pos", uv_pos)
	mat.set_shader_parameter("monitor_size", Vector2(0.4, 0.6)) 
	
	
	if zooming_in and player_camera and screen_camera_position:
		player_camera.global_transform = player_camera.global_transform.interpolate_with(
			screen_camera_position.global_transform, zoom_speed * delta
		)
		if player_camera.global_position.distance_to(screen_camera_position.global_position) < 0.05:
			zooming_in = false
			viewport.handle_input_locally = true
	
	if zoomed_in:
		$CharacterBody3D/Label.visible = false
	else:
		$CharacterBody3D/Label.visible = true
