class_name TaskRandomWalking
extends Task

func run(blackboard: Dictionary) -> void:
    var player: PlayerManager         = blackboard["player"]
    var navigation: TilemapNavigation = blackboard["navigation"]

    var direction: Vector2i = navigation.walking_directions[randi() % navigation.walking_directions.size()]
    var target: Vector2i    = player.board_position + direction

    player.walk_towards(target)

    status = SUCCESS
    status_reason = "Walking towards " + str(target)
