class_name PerformanceTimer
extends Node

var start_time: float       = 0.0
var accumulated_time: float = 0.0
var display_name: String    = ""


func _init() -> void:
    start_time = Time.get_unix_time_from_system()
    display_name = ""


func start() -> void:
    start_time = Time.get_unix_time_from_system()


func stop(printme: bool = true) -> void:
    var end_time: float    = Time.get_unix_time_from_system()
    var duration_ms: float = (end_time - start_time) * 1000
    accumulated_time += duration_ms
    if printme:
        printme()

func printme() -> void:
    print(display_name, " ", accumulated_time, "ms")

func per_count(n: String, count: int) -> void:
    print(display_name, " ", accumulated_time / count, "ms per ", n, " (", count, ")")
