class_name TaskGoToBoatLocation
extends Task

func run(blackboard: Dictionary) -> void:
    var navigation: TilemapNavigation = blackboard["navigation"]

    var result: Dictionary = find_closest_item(blackboard, tilemap_types.OBJECT_COLLECTION_BOAT, "boat_building_location", TileMapLayerAccess.ANY_DISTANCE)

    if result.status == FAILURE:
        status = FAILURE
        status_reason = result.status_reason
        return

    # var target: Vector2i = world.camp_manager.boat_build_location
    var target: Vector2i = result.closest_item

    var path: Array[Vector2i] = navigation.cached_path_allow_neighbors(blackboard, "path_to_boat", target)

    if path.size() > 0:
        blackboard["path"] = path
        status_reason = "Found path to boat build location"
        status = SUCCESS
    else:
        status = FAILURE
        status_reason = "No path found to boat build location " + str(target)
