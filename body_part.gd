extends Area2D

@onready var straight_sprite = $StraightSprite
@onready var turn_left_sprite = $TurnLeftSprite
@onready var bifurcate_sprite = $BifurcateSprite

func set_type(t: Globals.BodyPartType) -> void:
	match t:
		Globals.BodyPartType.STRAIGHT:
			straight_sprite.visible = true;
		
			
