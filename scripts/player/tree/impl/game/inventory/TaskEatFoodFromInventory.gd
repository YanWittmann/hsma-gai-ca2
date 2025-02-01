class_name TaskEatFoodFromInventory
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]

    if player.inventory_slot != tilemap_types.OBJECT_I_BERRY:
        status = FAILURE
        status_reason = "Inventory does not contain berry"
        return

    EventsTracker.track(EventsTracker.Event.PLAYER_USED_ITEM, {"item": player.inventory_slot})
    player.inventory_slot = tilemap_types.EMPTY
    player.food = player.max_food

    status = SUCCESS
    status_reason = "Ate berry, player now has " + str(player.food) + " food"
