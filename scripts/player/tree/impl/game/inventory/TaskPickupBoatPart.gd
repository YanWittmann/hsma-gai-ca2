class_name TaskPickupBoatPart
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager  = blackboard["player"]
    var closest_part: Vector2i = blackboard["closest_part"]

    player.pick_up_item(closest_part)
    player.player_memory.erase("boat_part")

    status = SUCCESS
    status_reason = "Picked up boat part"
