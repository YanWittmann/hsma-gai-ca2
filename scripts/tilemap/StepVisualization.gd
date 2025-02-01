class_name StepVisualization
extends Node2D

static var game_manager: GameManager
static var world: World
#
enum LineType { SEARCH_BASE, SEARCH_SELECTED, SEARCH_FAILED }
enum CircleType { PLAYER_VIEW, GOAL_CONSIDERATION, GOAL, BOAT_PART }
#
# Dictionary[Array[Vector2i], LineType] ([from, to], line_type)
static var draw_lines: Dictionary = {}
# Dictionary[Array[Vector2i], CircleType] ([center, radius], circle_type)
static var draw_circles: Dictionary = {}


static func add_line(from: Vector2i, to: Vector2i, line_type: LineType) -> void:
    draw_lines[[from, to]] = line_type


static func add_line_tileset(from: Vector2i, to: Vector2i, line_type: LineType) -> void:
    var from_tileset: Vector2i = world.tilemap_ground.cell_to_local(from)
    var to_tileset: Vector2i   = world.tilemap_ground.cell_to_local(to)
    draw_lines[[from_tileset, to_tileset]] = line_type


static func add_circle(center: Vector2i, radius: int, circle_type: CircleType) -> void:
    draw_circles[[center, radius]] = circle_type


static func add_circle_tileset(center: Vector2i, radius: int, circle_type: CircleType) -> void:
    var center_tileset: Vector2i = world.tilemap_ground.cell_to_local(center)
    radius *= world.tilemap_ground.tilemap.tile_set.tile_size.x
    draw_circles[[center_tileset, radius]] = circle_type


func game_tick_start():
    draw_lines.clear()
    draw_circles.clear()


func game_tick_end():
    queue_redraw()

var label_font = Control.new().get_theme_default_font()

@export var default_color: Color = Color("red")


func _ready() -> void:
    pass


func _draw() -> void:
    for key in draw_circles.keys():
        var center: Vector2i        = key[0]
        var radius: int             = key[1]
        var circle_type: CircleType = draw_circles[key]

        if circle_type == CircleType.PLAYER_VIEW:
            draw_circle(center, radius, Color("green"), false, 2, true)
        elif circle_type == CircleType.GOAL_CONSIDERATION:
            draw_circle(center, radius, Color("yellow"), false, 2, true)
        elif circle_type == CircleType.GOAL:
            draw_circle(center, radius, Color("orange"), false, 2, true)
        elif circle_type == CircleType.BOAT_PART:
            draw_circle(center, radius, Color(255, 0, 0, 0.5), false, 1, true)

    for key in draw_lines.keys():
        var from: Vector2i      = key[0]
        var to: Vector2i        = key[1]
        var line_type: LineType = draw_lines[key]

        if line_type == LineType.SEARCH_BASE:
            draw_line(from, to, Color("blue"), 1)
        elif line_type == LineType.SEARCH_SELECTED:
            draw_line(from, to, Color("green"), 2)
        elif line_type == LineType.SEARCH_FAILED:
            draw_line(from, to, Color(255, 0, 0, 0.1), 1)
