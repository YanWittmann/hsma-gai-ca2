class_name TaskPickupStick
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager   = blackboard["player"]
    var closest_stick: Vector2i = blackboard["closest_stick"]

    player.pick_up_item(closest_stick)

    status = SUCCESS
    status_reason = "Picked up stick"
