class_name TaskCheckBoatCompleted
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World = blackboard["world"]

    if world.camp_manager.boat_items.size() >= world.camp_manager.required_boat_parts:
        status = SUCCESS
        status_reason = "Boat is completed with " + str(world.camp_manager.boat_items.size()) + " parts"
        return

    status = FAILURE
    status_reason = "Boat is not completed, got only " + str(world.camp_manager.boat_items.size()) + " parts"
