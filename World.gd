extends Node3D

@export var camera : Camera3D

var target_scene : PackedScene = preload("res://target.tscn")

@onready var space_state := get_world_3d().direct_space_state

@onready var pivot := $"Universe Settings/Camera Pivot"

func _unhandled_input(event):
	if event is InputEventMouseButton:
		#print("Button click:" , event)
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			#On a left click, project our mouse into the 3D world and figure
			#out where we clicked.
			var mouse_pos := get_viewport().get_mouse_position()
			
			var origin = camera.project_ray_origin(mouse_pos)
			var end = origin + camera.project_ray_normal(mouse_pos) * camera.far
			
			#Cast button click from screen and determine what it impacts
			var query := PhysicsRayQueryParameters3D.create(
				origin,
				end
			)
			
			var result := space_state.intersect_ray(query)
			
			#result will be an empty dictionary if we don't hit anything, which,
			#while similar in meaning to null, is not the same. So I prefer to
			#check if it's empty directly. Alternatively, we could do
			#`if result:`, but I think that fails to communicate to the reader
			#what it's doing.
			if not result.is_empty():
				#Add a little blue bang so we can see where we clicked
				var target = target_scene.instantiate()
				add_child(target)
				target.global_position = result.position
				
				#And set the satellite's target position. Further processing
				#goes on in its set function, which is in another script.
				$Satellite.target_point = result.position
	elif event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			var motion : InputEventMouseMotion = event
			
			pivot.rotate_y(motion.relative.x * get_physics_process_delta_time())
			pivot.rotate_x(motion.relative.y * get_physics_process_delta_time())
	elif event is InputEventKey:
		var key_input : InputEventKey = event
		if key_input.keycode == KEY_KP_5:
			#Reset transform, Blender style
			pivot.transform = Transform3D.IDENTITY
