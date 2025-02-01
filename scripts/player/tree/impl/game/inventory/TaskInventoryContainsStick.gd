class_name TaskInventoryContainsStick
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]

    if player.inventory_slot == tilemap_types.OBJECT_I_STICK:
        status = SUCCESS
        status_reason = "Player has stick"
        return

    status = FAILURE
    status_reason = "Player does not have stick"
