class_name TaskFindClosestWarmTile
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World                  = blackboard["world"]
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    var warm_tiles: Array[Vector2i] = world.tilemap_temperature.get_cells_by_type(
                                          tilemap_types.TEMPERATURE_NORMAL,
                                          player.board_position, player.view_distance,
                                          false)
    if len(warm_tiles) == 0:
        status = FAILURE
        status_reason = "No warm tiles found"
        return

    var closest_warm_tile: Vector2i = navigation.manhattan_distance_closest(warm_tiles, player.board_position)
    StepVisualization.add_line_tileset(player.board_position, closest_warm_tile, StepVisualization.LineType.SEARCH_SELECTED)
    if closest_warm_tile == tilemap_types.NO_TILE_FOUND:
        status = FAILURE
        status_reason = "No closest warm tile found"
        return

    blackboard["closest_warm_tile"] = closest_warm_tile

    var path: Array[Vector2i] = navigation.find_path_allow_neighbors(player.board_position, closest_warm_tile, player.view_distance)
    if path.size() > 0:
        blackboard["path"] = path
        status_reason = "Found path to closest warm tile"
        status = SUCCESS
        return

    status = FAILURE
    status_reason = "No path found to closest warm tile " + str(closest_warm_tile)
