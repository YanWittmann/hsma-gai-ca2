class_name TaskFindClosestFood
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World                  = blackboard["world"]
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    var active_foods: Array[Vector2i] = world.tilemap_interactive.get_cells_by_type_collection(
                                            tilemap_types.OBJECT_COLLECTION_BERRY_SOURCE, player.board_position, player.view_distance)
    if len(active_foods) == 0:
        status = FAILURE
        status_reason = "No active foods found"
        return

    var closest_berry: Vector2i = navigation.manhattan_distance_closest(active_foods, player.board_position)
    StepVisualization.add_line_tileset(player.board_position, closest_berry, StepVisualization.LineType.SEARCH_SELECTED)
    if closest_berry == tilemap_types.NO_TILE_FOUND:
        status = FAILURE
        status_reason = "No closest berry found"
        return

    blackboard["closest_berry"] = closest_berry

    var path: Array[Vector2i] = navigation.find_path_allow_neighbors(player.board_position, closest_berry, player.view_distance)
    if path.size() > 0:
        blackboard["path"] = path
        status_reason = "Found path to closest berry"
        status = SUCCESS
        return

    status = FAILURE
    status_reason = "No path found to closest berry " + str(closest_berry)
