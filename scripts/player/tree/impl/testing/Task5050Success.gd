class_name Task5050Success
extends Task

func run(blackboard: Dictionary) -> void:
    var random: int = randi() % 2
    if random == 0:
        status = SUCCESS
    else:
        status = FAILURE
