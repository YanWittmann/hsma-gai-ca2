class_name TaskCheckFoodCritical
extends Task

func run(blackboard: Dictionary) -> void:
    var world: World                  = blackboard["world"]
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    if player.food > player.food_critical_threshold:
        status = FAILURE
        status_reason = "Player food is not critical (" + str(player.food) + " > " + str(player.food_critical_threshold) + ")"
        return

    status = SUCCESS
    status_reason = "Player food is critical (" + str(player.food) + " <= " + str(player.food_critical_threshold) + ")"
