extends Area2D

const sprite_size: int = 128

@onready var is_alive: bool = true
@onready var ray_cast_fw = $RayCastFW
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var alive_sprite = $AliveSprite
@onready var dead_sprite = $DeadSprite

signal request_spawn_right(global_transform: Transform2D)
signal request_body_part(global_transform: Transform2D, part_type: int)

signal died()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func tick() -> void:
	if not is_alive:
		return
	if ray_cast_fw.is_colliding():
		_handle_blocked_path()
	else:
		# todo: add body part
		_just_the_head_forward()

func _just_the_head_forward() -> void:
	position.y -= sprite_size
	

func _handle_blocked_path() -> void:
	var can_turn_left: bool = ray_cast_left.is_colliding()
	var can_turn_right: bool = ray_cast_right.is_colliding()
	
	if (not can_turn_left) and (not can_turn_right):
		is_alive = false;
		alive_sprite.visible = false
		dead_sprite.visible = true
		died.emit(global_transform)
		return
		
	if can_turn_left and not can_turn_right:
		#todo: request left turning body part
		rotation_degrees += 90;
		_just_the_head_forward()
		return
		
	if can_turn_right and not can_turn_left:
		#todo: request right turning body part
		rotation_degrees -= 90;
		_just_the_head_forward()
		return
	
	# got this far, can turn both ways, bifurcate!
	
	# todo: request bifurcating body part
	# request spawn right, then turn left
	request_spawn_right.emit(global_transform)
	rotation_degrees += 90;
	_just_the_head_forward()
