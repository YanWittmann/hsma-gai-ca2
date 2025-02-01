class_name TaskGoCloseToCamp
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager         = blackboard["player"]
    var world: World                  = blackboard["world"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    # allow a radius of the player view distance / 1.5 to find a camp
    var camp: Vector2i = world.camp_manager.camp
    if TilemapNavigation.manhattan_distance(player.board_position, camp) < player.view_distance / 1.5:
        blackboard["path"] = []
        status = SUCCESS
        status_reason = "Player is close to camp"
        return

    var path: Array[Vector2i] = navigation.cached_path_allow_neighbors(blackboard, "path_to_camp", camp, 99999999)
    if path.size() > 0:
        blackboard["path"] = path
        status = FAILURE
        status_reason = "Found path to camp"
        return

    status = FAILURE
    status_reason = "No path found to camp " + str(camp)
