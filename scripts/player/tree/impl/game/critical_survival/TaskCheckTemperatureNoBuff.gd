class_name TaskCheckTemperatureNoBuff
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]

    if player.temperature_buff_timer > 0:
        status = FAILURE
        status_reason = "Player already has a temperature buff: " + str(player.temperature_buff_timer)
        return

    status = SUCCESS
    status_reason = "Player does not have a temperature buff"
