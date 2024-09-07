extends Node2D

# these are for illusrationg the problems I had with collisions detection
@export_group("Collision detection strategies")
@export var await_physics_frame : bool = false
@export var force_raycast_update : bool = true


@export_group("Normal stuff")
#@export_color_no_alpha var background_color = Color("Pink")
@export var quadrant_size: Vector2i = Vector2i(17, 9)
@export_range(0.0, 1.0) var obsticle_probability: float = 0.03



@onready var walls = $Walls
@onready var obsticles = $Obsticles
@onready var body_parts = $SnakeBodyParts
@onready var tick_timer = $TickTimer
@onready var snake_heads = $SnakeHeads
@onready var camera_2d = $Camera2D

# constants for all the other scenes
const scene_body_part_name = "res://scenes/body_part.tscn"
const scene_brick_name = "res://scenes/brick.tscn"
const scene_obsticle_name = "res://scenes/obsticle.tscn"
const scene_sneak_head_name = "res://scenes/sneak_head.tscn"

# preloaded scenes
@onready var scene_body_part = preload(scene_body_part_name)
@onready var scene_brick = preload(scene_brick_name)
@onready var scene_obsticle = preload(scene_obsticle_name)
@onready var scene_sneak_head = preload(scene_sneak_head_name)

var _snake_head_count: int = 0
var _game_over: bool = false
var _tick_in_progress = false


func create_brick(pos: Vector2i):
	var brick = scene_brick.instantiate()
	brick.position = _get_world_cell_position(pos)
	walls.add_child(brick)

func _get_world_cell_position(pos: Vector2i) -> Vector2:
	return pos * Globals.CELL_SIZE

func _check_collision(pos: Vector2i) -> bool:
	var world_pos = _get_world_cell_position(pos)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.position = world_pos
	# use all layers # query.collision_mask = 1  # Adjust this to match your collision layer
	var result = space_state.intersect_point(query)
	return result.size() > 0

func _create_wall(start: Vector2i, direction: Vector2i, length: int):
	for i in range(length):
		var x: int = (start.x + i * direction.x)
		var y: int = (start.y + i * direction.y)
		create_brick(Vector2i(x, y))

# Called when the node enters the scene tree for the first time.
func _create_border():
	# define four quadrants
	var quadrants: Array[Vector2i]  = [
		Vector2i(-1, -1),
		Vector2i(-1, 1),
		Vector2i(1, -1),
		Vector2i(1, 1)
	]
	# use quadrant size to create two walls for each quadrant
	for quadrant in quadrants:
		var start_pos: Vector2i = quadrant * quadrant_size
		_create_wall(start_pos, Vector2i(0, -quadrant.y), quadrant_size.y)
		# refrain from creating a duplicate brick at the corner
		start_pos.x -= quadrant.x
		_create_wall(start_pos, Vector2i(-quadrant.x, 0), quadrant_size.x-1)

	# add three middle bricks, excluding the bottom
	create_brick(Vector2i(0, -quadrant_size.y))
	create_brick(Vector2i(-quadrant_size.x, 0))
	create_brick(Vector2i(quadrant_size.x, 0))


func _create_obsticles():
	var neighbors: Array[Vector2i] = [
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(0, -1),
		Vector2i(0, 1)
	]
	for x in range(-quadrant_size.x + 1, quadrant_size.x):
		for y in range(-quadrant_size.y + 1, quadrant_size.y):
			var pos = Vector2i(x, y)
			if randf() < obsticle_probability:
				# check collision with neighbours
				var is_free = true
				for neighbor in neighbors:
					var neighbor_pos = pos + neighbor
					if _check_collision(neighbor_pos):
						is_free = false
						break
				if is_free:
					var obsticle = scene_obsticle.instantiate()
					obsticle.position = _get_world_cell_position(pos)
					obsticles.add_child(obsticle)

func _ready():
	Globals.force_raycast_update = force_raycast_update
	randomize()
	
	_create_border()
	# create head
	var head: Node2D = _create_sneak_head()
	head.position = _get_world_cell_position(Vector2i(0, quadrant_size.y))
	_create_obsticles()
	tick_timer.start()

func _create_sneak_head() -> Node2D:
	var sneak_head = scene_sneak_head.instantiate()
	snake_heads.add_child(sneak_head)
	_snake_head_count += 1

	# Connect all signals
	sneak_head.request_spawn_right.connect(_on_snake_head_request_spawn_right)
	sneak_head.request_body_part.connect(_on_snake_head_request_body_part)
	sneak_head.died.connect(_on_snake_head_died)

	return sneak_head

# Signal handlers
func _on_snake_head_request_spawn_right(new_global_transform: Transform2D):
	# create a new head at the requested transform
	var new_head = _create_sneak_head()
	new_head.global_transform = new_global_transform
	# turn right and move forward
	new_head.rotation_degrees += 90
	new_head.forward()

func _on_snake_head_request_body_part(new_global_transform: Transform2D, part_type: int) -> void:
	var body_part = scene_body_part.instantiate()
	body_part.set_type(part_type)
	body_part.global_transform = new_global_transform
	body_parts.add_child(body_part)


func _on_snake_head_died():
	_snake_head_count -= 1
	if _snake_head_count == 0:
		_game_over = true


func _on_tick_timer_timeout():
	if _tick_in_progress:
		return
	_tick_in_progress = true
	var heads: Array[Node] = snake_heads.get_children()
	for head in heads:
		head.tick()
		# colisions may have changed, wait for next calculation
		if await_physics_frame:
			await get_tree().physics_frame
		#if head.tick():
			## colisions may have changed, wait for next calculation
			#await get_tree().physics_frame
	_tick_in_progress = false

	
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept") and _game_over:
		get_tree().reload_current_scene()
	elif Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()
	
