extends Node2D

@export var quadrant_size: Vector2i = Vector2i(17, 9)
@onready var walls = $Walls

# constants for all the other scenes
const SCENE_BODY_PART = preload("res://scenes/body_part.tscn")
const SCENE_BRICK = preload("res://scenes/brick.tscn")
const SCENE_OBSTACLE = preload("res://scenes/obsticle.tscn")
const SCENE_SNEAK_HEAD = preload("res://scenes/sneak_head.tscn")

func create_brick(pos: Vector2i):
	var brick = SCENE_BRICK.instantiate()
	brick.position = pos * Globals.CELL_SIZE
	walls.add_child(brick)

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
	

func _ready():
	_create_border()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
