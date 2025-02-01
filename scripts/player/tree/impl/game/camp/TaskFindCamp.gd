class_name TaskFindCamp
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World                  = blackboard["world"]
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    blackboard["location_camp"] = world.camp_manager.camp

    var path: Array[Vector2i] = navigation.cached_path_allow_neighbors(blackboard, "path_to_camp", world.camp_manager.camp, 99999999)
    if path.size() > 0:
        blackboard["path"] = path
        status = SUCCESS
        status_reason = "Found camp at " + str(blackboard["location_camp"])
        return

    status = FAILURE
    status_reason = "No path found to camp " + str(blackboard["location_camp"])
