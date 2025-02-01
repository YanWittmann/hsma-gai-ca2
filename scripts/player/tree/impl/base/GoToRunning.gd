class_name GoToRunning
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    if not blackboard.has("path"):
        status = FAILURE
        status_reason = "blackboard did not have path"
        return

    var path: Array[Vector2i] = blackboard["path"]
    if path.size() == 0:
        status = FAILURE
        status_reason = "path was empty"
        return

    player.walk_along(path)

    if navigation.has_arrived(player.board_position, path):
        blackboard["cached_paths"] = {}
        status = SUCCESS
        status_reason = "already arrived at destination"
        return

    status = RUNNING
    status_reason = "walked along path, now at " + str(player.board_position)
