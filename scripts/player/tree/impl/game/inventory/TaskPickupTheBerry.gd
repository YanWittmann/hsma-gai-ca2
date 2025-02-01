class_name TaskPickupTheBerry
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager   = blackboard["player"]
    var closest_berry: Vector2i = blackboard["closest_berry"]

    player.pick_up_item(closest_berry)

    status = SUCCESS
    status_reason = "Picked up berry"
