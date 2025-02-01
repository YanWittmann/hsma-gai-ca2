class_name TaskDeliverBoatPart
extends Task

func run(blackboard: Dictionary) -> void:
	var world: World                  = blackboard["world"]
	var player: PlayerManager         = blackboard["player"]

	if tilemap_types.is_part_of_collection(tilemap_types.OBJECT_COLLECTION_BOAT_PARTS, player.inventory_slot):
		EventsTracker.track(EventsTracker.Event.CAMP_BOAT_PART_DELIVERED, {"item": player.inventory_slot})
		world.camp_manager.boat_items.append(player.inventory_slot)
		player.inventory_slot = tilemap_types.EMPTY
		if world.camp_manager.boat_items.size() >= world.camp_manager.required_boat_parts:
			EventsTracker.track(EventsTracker.Event.CAMP_BOAT_COMPLETE, {"item": tilemap_types.OBJECT_I_BOAT_WITH_ENGINE})
			world.tilemap_interactive.set_cell(world.camp_manager.boat_build_location, tilemap_types.OBJECT_I_BOAT_WITH_ENGINE)
		status = SUCCESS
		status_reason = "Player delivered boat part"
		return

	status = FAILURE
	status_reason = "Player does not have boat part to deliver"
