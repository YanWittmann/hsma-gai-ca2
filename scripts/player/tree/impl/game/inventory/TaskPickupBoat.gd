class_name TaskPickupBoat
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]

    var result: Dictionary = find_closest_item(blackboard, tilemap_types.OBJECT_COLLECTION_BOAT, "boat_building_location", TileMapLayerAccess.ANY_DISTANCE)

    if result.status == FAILURE:
        status = FAILURE
        status_reason = result.status_reason
        return

    player.pick_up_item(result.closest_item)
    status = SUCCESS
    status_reason = "Picked up boat"
