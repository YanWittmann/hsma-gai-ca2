class_name Task5050Running
extends Task

func run(blackboard: Dictionary) -> void:
    var random: int = randi() % 2
    if random == 0:
        status = RUNNING
    else:
        status = SUCCESS
