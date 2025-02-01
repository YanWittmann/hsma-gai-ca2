class_name WalkToMouse
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World                          = blackboard["world"]
    var player: PlayerManager                 = blackboard["player"]
    var tilemap_navigation: TilemapNavigation = blackboard["navigation"]

    var path: Array[Vector2i] = tilemap_navigation.find_path(player.board_position, world.tilemap_mouse_position(), player.view_distance)
    if len(path) == 0:
        status = FAILURE

    player.walk_along(path)
    status = SUCCESS
