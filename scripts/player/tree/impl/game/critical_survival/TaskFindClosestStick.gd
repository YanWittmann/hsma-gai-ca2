class_name TaskFindClosestStick
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World                  = blackboard["world"]
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    var sticks: Array[Vector2i] = world.tilemap_interactive.get_cells_by_type_collection(
                                            tilemap_types.OBJECT_COLLECTION_STICK_SOURCE, player.board_position, player.view_distance)
    if len(sticks) == 0:
        status = FAILURE
        status_reason = "No active sticks found"
        return

    var closest_stick: Vector2i = navigation.manhattan_distance_closest(sticks, player.board_position)
    StepVisualization.add_line_tileset(player.board_position, closest_stick, StepVisualization.LineType.SEARCH_SELECTED)
    if closest_stick == tilemap_types.NO_TILE_FOUND:
        status = FAILURE
        status_reason = "No closest stick found"
        return

    blackboard["closest_stick"] = closest_stick

    var path: Array[Vector2i] = navigation.find_path_allow_neighbors(player.board_position, closest_stick, player.view_distance)
    if path.size() > 0:
        blackboard["path"] = path
        status_reason = "Found path to closest stick"
        status = SUCCESS
        return

    status = FAILURE
    status_reason = "No path found to closest stick " + str(closest_stick)
