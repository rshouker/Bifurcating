extends Area2D

@onready var straight_sprite = $StraightSprite
@onready var turn_left_sprite = $TurnLeftSprite
@onready var bifurcate_sprite = $BifurcateSprite

var _type: Globals.BodyPartType

#called before _ready
func set_type(t: Globals.BodyPartType) -> void:
	_type = t
	
func _ready():
	match _type:
		Globals.BodyPartType.STRAIGHT:
			straight_sprite.visible = true;
		Globals.BodyPartType.TURN_LEFT:
			turn_left_sprite.visible = true;
		Globals.BodyPartType.TURN_RIGHT:
			turn_left_sprite.flip_h = true;
			turn_left_sprite.visible = true;
		Globals.BodyPartType.BIFURCATE:
			bifurcate_sprite.visible = true;
