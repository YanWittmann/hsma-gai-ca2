class_name TileMapTileTypes

# global values
const EMPTY: Vector2i         = Vector2i(-1, -1)
const NO_TILE_FOUND: Vector2i = Vector2i(-999999, -999999)
#
# ground, sid = 0
const GROUND_GRASS: Vector2i         = Vector2i(0, 0)
const GROUND_WATER_SHALLOW: Vector2i = Vector2i(1, 0)
const GROUND_WATER_DEEP: Vector2i    = Vector2i(2, 0)
const GROUND_SAND: Vector2i          = Vector2i(3, 0)
const GROUND_DOCK: Vector2i          = Vector2i(3, 0)
#
# objects, sid = 1
# NI = not interactive
const OBJECT_NI_RANDOM_1: Vector2i = Vector2i(0, 0) # testing only, to be removed
const OBJECT_NI_RANDOM_2: Vector2i = Vector2i(1, 0) # testing only, to be removed
const OBJECT_NI_ROCK_1: Vector2i   = Vector2i(2, 0)
#
# I = interactive
# boat
const OBJECT_I_BOAT_NO_ENIGNE: Vector2i   = Vector2i(0, 4)
const OBJECT_I_BOAT_WITH_ENGINE: Vector2i = Vector2i(2, 4)
# boat parts
const OBJECT_I_BOAT_PART_GENERIC: Vector2i   = Vector2i(1, 1)
const OBJECT_I_BOAT_PART_ENGINE: Vector2i    = Vector2i(0, 1)
const OBJECT_I_BOAT_PART_FUEL: Vector2i      = Vector2i(1, 1)
const OBJECT_I_BOAT_PART_ANCHOR: Vector2i    = Vector2i(2, 1)
const OBJECT_I_BOAT_PART_CHEST: Vector2i     = Vector2i(0, 2)
const OBJECT_I_BOAT_PART_GEARS: Vector2i     = Vector2i(1, 2)
const OBJECT_I_BOAT_PART_MEDIKIT: Vector2i   = Vector2i(2, 2)
const OBJECT_I_BOAT_PART_PADDLE: Vector2i    = Vector2i(3, 2)
const OBJECT_I_BOAT_PART_GAS_STOVE: Vector2i = Vector2i(4, 2)
# camp
const OBJECT_I_TENT: Vector2i        = Vector2i(6, 2)
const OBJECT_I_FIREPIT_OFF: Vector2i = Vector2i(6, 1)
const OBJECT_I_FIREPIT_ON: Vector2i  = Vector2i(7, 1)
# other
const OBJECT_I_EMPTY_BUSH: Vector2i  = Vector2i(3, 0)
const OBJECT_I_FILLED_BUSH: Vector2i = Vector2i(3, 1)
const OBJECT_I_BERRY: Vector2i       = Vector2i(0, 5)
const OBJECT_I_STICK: Vector2i       = Vector2i(1, 5)
const OBJECT_I_TREE_FULL: Vector2i   = Vector2i(4, 0)
const OBJECT_I_TREE_CUT: Vector2i    = Vector2i(5, 0)
# collections
const OBJECT_COLLECTION_BERRY_SOURCE: Array[Vector2i] = [OBJECT_I_FILLED_BUSH, OBJECT_I_BERRY]
const OBJECT_COLLECTION_STICK_SOURCE: Array[Vector2i] = [OBJECT_I_TREE_FULL, OBJECT_I_STICK]
const OBJECT_COLLECTION_FIREPIT: Array[Vector2i]      = [OBJECT_I_FIREPIT_OFF, OBJECT_I_FIREPIT_ON]
const OBJECT_COLLECTION_BOAT_PARTS: Array[Vector2i]   = [ # @formatter:off
	OBJECT_I_BOAT_PART_GENERIC,
	OBJECT_I_BOAT_PART_ENGINE, OBJECT_I_BOAT_PART_FUEL, OBJECT_I_BOAT_PART_ANCHOR,
	OBJECT_I_BOAT_PART_CHEST, OBJECT_I_BOAT_PART_GEARS, OBJECT_I_BOAT_PART_MEDIKIT,
	OBJECT_I_BOAT_PART_PADDLE, OBJECT_I_BOAT_PART_GAS_STOVE
] # @formatter:on
const OBJECT_COLLECTION_BOAT: Array[Vector2i]        = [OBJECT_I_BOAT_NO_ENIGNE, OBJECT_I_BOAT_WITH_ENGINE]
#
# temperature, sid = 2
const TEMPERATURE_NORMAL: Vector2i = Vector2i(2, 0)
const TEMPERATURE_COLD_1: Vector2i = Vector2i(0, 0)
const TEMPERATURE_COLD_2: Vector2i = Vector2i(1, 0)
#
const NAVIGATION_CHECKED: Vector2i = Vector2i(0, 1)
const NAVIGATION_TARGET: Vector2i  = Vector2i(3, 1)
const NAVIGATION_CHOSEN: Vector2i  = Vector2i(1, 1)
const NAVIGATION_FAILED: Vector2i  = Vector2i(2, 1)
#
# player, sid = 3
const PLAYER_DOWN: Vector2i  = Vector2i(0, 0)
const PLAYER_UP: Vector2i    = Vector2i(1, 0)
const PLAYER_LEFT: Vector2i  = Vector2i(2, 0)
const PLAYER_RIGHT: Vector2i = Vector2i(3, 0)
#
const PLAYER_COLLECTION: Array[Vector2i] = [PLAYER_DOWN, PLAYER_UP, PLAYER_LEFT, PLAYER_RIGHT]


func player_sprite_from_direction(direction: Vector2i) -> Vector2i:
	if direction == Vector2i(0, 1):
		return PLAYER_DOWN
	if direction == Vector2i(0, -1):
		return PLAYER_UP
	if direction == Vector2i(-1, 0):
		return PLAYER_LEFT
	if direction == Vector2i(1, 0):
		return PLAYER_RIGHT
	return PLAYER_DOWN

func is_part_of_collection(collection: Array[Vector2i], item: Vector2i) -> bool:
	return collection.find(item) != -1
