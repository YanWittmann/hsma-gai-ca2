class_name World
extends Node2D

var tilemap_types: TileMapTileTypes = TileMapTileTypes.new()
# tilemap layers
var tilemap_ground: TileMapLayerAccess          = TileMapLayerAccess.new()
var tilemap_non_interactive: TileMapLayerAccess = TileMapLayerAccess.new()
var tilemap_interactive: TileMapLayerAccess     = TileMapLayerAccess.new()
var tilemap_player: TileMapLayerAccess          = TileMapLayerAccess.new()
var tilemap_temperature: TileMapLayerAccess     = TileMapLayerAccess.new()
var tilemap_nav_vis: TileMapLayerAccess         = TileMapLayerAccess.new()
# managers
var camp_manager: CampManager = CampManager.new()

# visualization
@onready var step_visualizer: StepVisualization = $StepVisualization


func _ready() -> void:
    tilemap_ground.sid = 0
    tilemap_ground.tilemap = $GroundLayer
    tilemap_non_interactive.sid = 1
    tilemap_non_interactive.tilemap = $NonInteractiveObjectsLayer
    tilemap_interactive.sid = 1
    tilemap_interactive.tilemap = $InteractiveObjectsLayer
    tilemap_player.sid = 3
    tilemap_player.tilemap = $PlayerLayer
    tilemap_temperature.sid = 2
    tilemap_temperature.tilemap = $TemperatureLayer
    tilemap_nav_vis.sid = 2
    tilemap_nav_vis.tilemap = $NavigationVisualization

    tilemap_ground.setup()
    tilemap_non_interactive.setup()
    tilemap_interactive.setup()
    tilemap_player.setup()
    tilemap_temperature.setup()

    call_deferred("defer_ready")


func defer_ready() -> void:
    camp_manager.setup()


# example usage
# tilemap_temperature.fill_area(Vector2i(0, 0), Vector2i(10, 10), tilemap_types.TEMPERATURE_COLD_1)
# tilemap_temperature.fill_area(Vector2i(4, 4), Vector2i(6, 6), tilemap_types.TEMPERATURE_NORMAL)
# print(tilemap_non_interactive.get_cells_by_custom_data("walkable", true))
# tilemap_ground.clear_cells()
# tilemap_ground.set_cell(Vector2i(0, 0), tilemap_types.GROUND_GRASS)
# print(tilemap_ground.local_to_cell(get_local_mouse_position()))

func tilemap_mouse_position() -> Vector2i:
    return tilemap_ground.local_to_cell(get_local_mouse_position())


func find_item_drop_location(center_pos: Vector2i) -> Vector2i:
    for x in range(center_pos.x - 1, center_pos.x + 1):
        for y in range(center_pos.y - 1, center_pos.y + 1):
            var check_pos: Vector2i = Vector2i(x, y)
            if not tilemap_interactive.get_cell(check_pos) and is_walkable(check_pos):
                return check_pos
    for x in range(center_pos.x - 2, center_pos.x + 2):
        for y in range(center_pos.y - 2, center_pos.y + 2):
            var check_pos: Vector2i = Vector2i(x, y)
            if not tilemap_interactive.get_cell(check_pos) and is_walkable(check_pos):
                return check_pos
    return Vector2i(-1, -1)


func is_walkable(position: Vector2i) -> bool:
    var ground_tile_walkable: bool     = tilemap_ground.get_custom_data(position, "walkable", false)
    var non_interactive_walkable: bool = tilemap_non_interactive.get_custom_data(position, "walkable", true)
    var interactive_walkable: bool     = tilemap_interactive.get_custom_data(position, "walkable", true)

    return ground_tile_walkable and non_interactive_walkable and interactive_walkable


func game_tick_start() -> void:
    step_visualizer.game_tick_start()
    camp_manager.game_tick_start()

    # refill empty bushes
    var empty_bushes: Array[Vector2i] = tilemap_interactive.get_cells_by_type(tilemap_types.OBJECT_I_EMPTY_BUSH)
    for bush in empty_bushes:
        if randf() < 0.01:
            tilemap_interactive.set_cell(bush, tilemap_types.OBJECT_I_FILLED_BUSH)

    # refill empty trees
    var empty_trees: Array[Vector2i] = tilemap_interactive.get_cells_by_type(tilemap_types.OBJECT_I_TREE_CUT)
    for tree in empty_trees:
        if randf() < 0.01:
            tilemap_interactive.set_cell(tree, tilemap_types.OBJECT_I_TREE_FULL)

    # mark all boat parts on the map
    var boat_parts: Array[Vector2i] = tilemap_interactive.get_cells_by_type_collection(tilemap_types.OBJECT_COLLECTION_BOAT_PARTS)
    for part in boat_parts:
        StepVisualization.add_circle_tileset(part, 1, StepVisualization.CircleType.BOAT_PART)


func game_tick_end() -> void:
    step_visualizer.game_tick_end()
    camp_manager.game_tick_end()
