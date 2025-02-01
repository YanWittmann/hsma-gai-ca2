class_name WalkUpToMouse
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World                          = blackboard["world"]
    var player: PlayerManager                 = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    # var path: Array[Vector2i] = navigation.find_path_allow_neighbors(player.board_position, world.tilemap_mouse_position(), player.view_distance)
    var path: Array[Vector2i] = navigation.cached_path_allow_neighbors(blackboard, "path_to_boat_part", world.tilemap_mouse_position(), player.view_distance * 1.4)
    if len(path) == 0:
        status = FAILURE

    player.walk_along(path)
    status = SUCCESS
