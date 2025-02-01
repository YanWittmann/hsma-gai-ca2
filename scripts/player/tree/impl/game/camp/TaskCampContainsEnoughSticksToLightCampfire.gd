class_name TaskCampContainsEnoughSticksToLightCampfire
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World          = blackboard["world"]

    if world.camp_manager.camp_contains_enough_sticks_to_light_campfire():
        status = SUCCESS
        status_reason = "Camp contains enough sticks to light campfire"
        return

    status = FAILURE
    status_reason = "Camp does not contain enough sticks to light campfire"
