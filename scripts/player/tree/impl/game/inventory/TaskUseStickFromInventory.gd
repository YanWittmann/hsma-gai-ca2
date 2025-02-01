class_name TaskUseStickFromInventory
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]

    if player.inventory_slot != tilemap_types.OBJECT_I_STICK:
        status = FAILURE
        status_reason = "Player does not have a stick in inventory"
        return

    EventsTracker.track(EventsTracker.Event.PLAYER_USED_ITEM, {"item": player.inventory_slot})
    player.inventory_slot = tilemap_types.EMPTY
    player.temperature_buff_timer = player.temperature_set_buff_value
    status = SUCCESS
    status_reason = "Player used a stick from inventory, now has temperature buff: " + str(player.temperature_buff_timer)
