class_name TaskFindClosestBoatPart
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    if tilemap_types.is_part_of_collection(tilemap_types.OBJECT_COLLECTION_BOAT_PARTS, player.inventory_slot):
        status = FAILURE
        status_reason = "Player already has boat part"
        return

    var result: Dictionary = find_closest_item(blackboard, tilemap_types.OBJECT_COLLECTION_BOAT_PARTS, "boat_part")

    if result.status == FAILURE:
        status = FAILURE
        status_reason = result.status_reason
        return

    var closest_part: Vector2i = result.closest_item
    blackboard["closest_part"] = closest_part

    var path: Array[Vector2i] = navigation.cached_path_allow_neighbors(blackboard, "path_to_boat_part", closest_part, player.view_distance * 1.5)
    if path.size() > 0:
        blackboard["path"] = path
        status_reason = "Found path to closest boat part"
        status = SUCCESS
        return

    status = FAILURE
    status_reason = "No path found to closest boat part " + str(closest_part)
