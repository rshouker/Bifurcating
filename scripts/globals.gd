extends Node

enum BodyPartType {
	STRAIGHT,
	TURN_LEFT,
	TURN_RIGHT,
	BIFURCATE
}

const CELL_SIZE: int = 128

var force_raycast_update: bool
