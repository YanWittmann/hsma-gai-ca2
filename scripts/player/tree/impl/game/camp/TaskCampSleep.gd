class_name TaskCampSleep
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]
    var world: World          = blackboard["world"]

    if not world.camp_manager.is_sleep_active and world.camp_manager.is_sundown():
        world.camp_manager.campfire_light()
        world.camp_manager.sleep_effect()
        player.health = player.max_health
        status = RUNNING
        status_reason = "Sleeping"
        return

    if world.camp_manager.is_sleep_active:
        player.food += 1
        status = RUNNING
        status_reason = "Still sleeping"
        return

    world.camp_manager.campfire_extinguish()
    status = SUCCESS
    status_reason = "Slept"
