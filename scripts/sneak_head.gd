extends Area2D

const sprite_size: int = 128

@onready var is_alive: bool = true
@onready var ray_cast_fw = $RayCastFW
@onready var ray_cast_left = $RayCastLeft
@onready var ray_cast_right = $RayCastRight
@onready var alive_sprite = $AliveSprite
@onready var dead_sprite = $DeadSprite
@onready var next_pos = $NextPos

signal request_spawn_right(global_transform: Transform2D)
signal request_body_part(global_transform: Transform2D, part_type: int)
signal died()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func tick() -> bool:
	if not is_alive:
		return false
	if ray_cast_fw.is_colliding():
		_handle_blocked_path()
	else:
		request_body_part.emit(global_transform, Globals.BodyPartType.STRAIGHT)
		forward()
	return true

func forward() -> void:
	global_position = next_pos.global_position


func _handle_blocked_path() -> void:
	var can_turn_left: bool = not ray_cast_left.is_colliding()
	var can_turn_right: bool = not ray_cast_right.is_colliding()

	if (not can_turn_left) and (not can_turn_right):
		is_alive = false;
		alive_sprite.visible = false
		dead_sprite.visible = true
		died.emit()
		return

	if can_turn_left and not can_turn_right:
		request_body_part.emit(global_transform, Globals.BodyPartType.TURN_LEFT)
		rotation_degrees -= 90;
		forward()
		return

	if can_turn_right and not can_turn_left:
		request_body_part.emit(global_transform, Globals.BodyPartType.TURN_RIGHT)
		rotation_degrees += 90;
		forward()
		return

	# got this far, can turn both ways, bifurcate!

	request_body_part.emit(global_transform, Globals.BodyPartType.BIFURCATE)
	# request spawn right, then turn left
	request_spawn_right.emit(global_transform)
	rotation_degrees -= 90;
	forward()
