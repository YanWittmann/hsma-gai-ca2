class_name TaskGoToBoatLeaveLocation
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World                  = blackboard["world"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    var target: Vector2i      = world.camp_manager.boat_leave_location
    var path: Array[Vector2i] = navigation.cached_path_allow_neighbors(blackboard, "path_to_boat_leave", target)

    if path.size() > 0:
        blackboard["path"] = path
        status_reason = "Found path to boat leave location"
        status = SUCCESS
    else:
        status = FAILURE
        status_reason = "No path found to boat leave location " + str(target)
