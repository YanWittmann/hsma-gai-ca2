class_name TaskCheckTemperatureCold
extends Task

var last_temperature: float = 0


func run(blackboard: Dictionary) -> void:
    var player: PlayerManager = blackboard["player"]

    var current_temperature: int = player.get_current_temperature()

    var temperature_changed: bool = current_temperature != last_temperature
    var temperature_cold: bool    = current_temperature > 0

    if temperature_changed and temperature_cold:
        EventsTracker.track(EventsTracker.Event.TEMPERATURE_COLD, {"temperature": current_temperature})

    if temperature_changed:
        last_temperature = current_temperature

    if temperature_cold:
        status = SUCCESS
        status_reason = "cold: " + str(current_temperature)
        return

    status = FAILURE
    status_reason = "not cold: " + str(current_temperature)
