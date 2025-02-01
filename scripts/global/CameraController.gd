class_name CameraController
extends Camera2D

@onready var shader_vignette: ColorRect = $CanvasLayer/Vignette

@export var border_acceleration: float = 2000.0
@export var max_speed: float = 500.0
@export var inner_border_threshold: float = 0.0 # 60.0
@export var outer_border_threshold: float = 0.0 # 40.0
@export var min_position: Vector2 = Vector2(874, 843)
@export var max_position: Vector2 = Vector2(4884, 4623)

var velocity: Vector2 = Vector2.ZERO
#
var drag_active: bool = false
var drag_start: Vector2
#
const DISABLE_FORCE: Vector2 = Vector2(-1, -1)
#
var force_target_position: Vector2 = DISABLE_FORCE
var force_zoom: Vector2            = DISABLE_FORCE


func go_to_zooming(position: Vector2, zoom: float) -> void:
    force_target_position = position
    force_zoom = Vector2(zoom, zoom)


func go_to(position: Vector2) -> void:
    force_target_position = position


func print_config() -> void:
    print("camera.go_to_zooming(Vector2(", position.x, ", ", position.y, "), ", zoom.x, ")")


func map_range(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
    return to_min + (value - from_min) / (from_max - from_min) * (to_max - to_min)


func _input(event):
    if event is InputEventMouseButton:
        if force_zoom == DISABLE_FORCE:
            if event.button_index == MOUSE_BUTTON_WHEEL_UP:
                zoom = zoom * 1.1
            elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
                zoom = zoom / 1.1


func _process(delta):
    if Input.is_action_just_pressed("camera_drag"):
        drag_active = true
        drag_start = get_viewport().get_mouse_position()
    if Input.is_action_just_released("camera_drag"):
        drag_active = false
    if drag_active:
        var drag_end: Vector2    = get_viewport().get_mouse_position()
        var drag_offset: Vector2 = drag_end - drag_start
        drag_start = drag_end
        position -= drag_offset / zoom

    if force_target_position != DISABLE_FORCE:
        # move towards the target position
        var offset: Vector2 = force_target_position - position
        position += offset * 0.1
        if offset.length() < 1:
            force_target_position = DISABLE_FORCE
    if force_zoom != DISABLE_FORCE:
        # move towards the target zoom
        var offset: Vector2 = force_zoom - zoom
        zoom += offset * 0.04
        if offset.length() < 0.02:
            force_zoom = DISABLE_FORCE
    else:
        var is_zoom_in: bool  = Input.is_action_pressed("camera_zoom_in")
        var is_zoom_out: bool = Input.is_action_pressed("camera_zoom_out")

        if is_zoom_in:
            zoom = zoom * 1.02
        elif is_zoom_out:
            zoom = zoom / 1.02

    if zoom.length() < 0.2:
        zoom = Vector2(1, 1).normalized() * 0.2
    elif zoom.length() > 10:
        zoom = Vector2(1, 1).normalized() * 10

    var mouse_pos: Vector2    = get_viewport().get_mouse_position()
    var screen_size: Vector2  = get_viewport().get_visible_rect().size
    var acceleration: Vector2 = Vector2.ZERO

    # the bigger the viewport size, the bigger the border threshold
    var border_threshold_addition: float = max(0, map_range(screen_size.length(), 1320, 2600, 0, 100))

    var is_up: bool    = Input.is_action_pressed("camera_up") or mouse_pos.y < inner_border_threshold + border_threshold_addition and mouse_pos.y > -outer_border_threshold
    var is_down: bool  = Input.is_action_pressed("camera_down") or mouse_pos.y > screen_size.y - inner_border_threshold - border_threshold_addition and mouse_pos.y < screen_size.y + outer_border_threshold
    var is_left: bool  = Input.is_action_pressed("camera_left") or mouse_pos.x < inner_border_threshold + border_threshold_addition and mouse_pos.x > -outer_border_threshold
    var is_right: bool = Input.is_action_pressed("camera_right") or mouse_pos.x > screen_size.x - inner_border_threshold - border_threshold_addition and mouse_pos.x < screen_size.x + outer_border_threshold

    if is_left:
        acceleration.x = -border_acceleration
    elif is_right:
        acceleration.x = border_acceleration

    if is_up:
        acceleration.y = -border_acceleration
    elif is_down:
        acceleration.y = border_acceleration

    acceleration *= Vector2.ONE / zoom

    if acceleration.length() > 0:
        # if the acceleration is the opposite direction of the velocity, double the acceleration
        if acceleration.dot(velocity) < 0:
            acceleration = acceleration * 2
        velocity = velocity + acceleration * delta
    else:
        velocity = velocity.move_toward(Vector2.ZERO, border_acceleration * delta)

    if velocity.length() > max_speed:
        velocity = velocity.normalized() * max_speed

    var target_offset   = velocity * delta
    var target_position = position + target_offset
    target_position.x = clamp(target_position.x, min_position.x, max_position.x)
    target_position.y = clamp(target_position.y, min_position.y, max_position.y)

    var offset: Vector2 = target_position - position
    position += offset


# SECTION: shader access

func set_vignette_intensity(value: float) -> void:
    var material: ShaderMaterial = shader_vignette.material
    material.set_shader_parameter("vignette_strength", value)
