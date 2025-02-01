class_name TaskWinningSequence
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World          = blackboard["world"]
    var player: PlayerManager = blackboard["player"]

    world.tilemap_interactive.set_cell(world.camp_manager.boat_leave_location, player.inventory_slot)
    EventsTracker.track(EventsTracker.Event.PLAYER_USED_ITEM, {"item": player.inventory_slot})
    player.inventory_slot = tilemap_types.EMPTY

    blackboard["game_state_win"] = true
