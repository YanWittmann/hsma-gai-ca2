class_name TaskCheckFoodBaseThreshold
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]

    if player.food > player.food_base_threshold:
        status = FAILURE
        status_reason = "Player food is not base threshold (" + str(player.food) + " > " + str(player.food_critical_threshold) + ")"
        return

    status = SUCCESS
    status_reason = "Player food is base threshold (" + str(player.food) + " <= " + str(player.food_critical_threshold) + ")"
