class_name TaskPutInventoryContentInCamp
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]
    var world: World          = blackboard["world"]

    if player.inventory_slot != tilemap_types.EMPTY:
        world.camp_manager.camp_add_item(player.inventory_slot)
        player.inventory_slot = tilemap_types.EMPTY
        status = SUCCESS
        status_reason = "Put inventory content in camp"
        return

    status = FAILURE
    status_reason = "Player has no inventory content"
