class_name TaskWantsToSleep
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World = blackboard["world"]

    if world.camp_manager.is_sundown():
        status = SUCCESS
        status_reason = "It is sundown " + str(world.camp_manager.time_of_day)
        return

    status = FAILURE
    status_reason = "It is not sundown " + str(world.camp_manager.time_of_day)
