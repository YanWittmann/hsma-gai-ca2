class_name TaskInventoryContainsBoat
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]

    if tilemap_types.is_part_of_collection(tilemap_types.OBJECT_COLLECTION_BOAT, player.inventory_slot):
        status = SUCCESS
        status_reason = "Player has boat"
        return

    status = FAILURE
    status_reason = "Player does not have boat"
