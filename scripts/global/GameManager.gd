class_name GameManager
extends Node

var tilemap_types: TileMapTileTypes = TileMapTileTypes.new()

@onready var world: World = $Tileset
@onready var player: PlayerManager = $PlayerManager
@onready var camera: CameraController = $Camera2D as CameraController
@onready var game_ticker: Timer = $GameTick
#
@onready var health_bar: ProgressBar = %HealthBar
@onready var food_bar: ProgressBar = %FoodBar
@onready var temperature_bar: ProgressBar = %TemperatureBar
@onready var temperature_resistance_bar: ProgressBar = %TemperatureResistanceBar
@onready var time_of_day_bar: ProgressBar = %TimeOfDayBar

var tilemap_navigation: TilemapNavigation = TilemapNavigation.new()

@onready var tree_visualizer: BehaviorTreeVisualizer = %TreeVisualizer

#
var waiting_for_input: bool = true

@onready var intro_image: Sprite2D = $Camera2D/IntroImage


func _ready() -> void:
    tilemap_navigation.world = world
    tilemap_navigation.player = player
    player.game_manager = self
    world.camp_manager.game_manager = self
    world.step_visualizer.game_manager = self
    world.step_visualizer.world = world
    update_bars()
    call_deferred("defer_ready")


func defer_ready() -> void:
    tree_visualizer.behavior_tree = player.behavior_tree
    tree_visualizer.build_tree()

    intro_image.visible = true
    await wait_for_key_press()
    get_tree().create_tween().tween_method(set_intro_opacity, 1.0, 0.0, 1.0)
    get_tree().create_tween().tween_method(set_instructions_opacity, 0.0, 1.0, 1.0)


func _process(delta: float) -> void:
    if Input.is_action_just_pressed("force_game_tick"):
        Task.print_behavior_tree_evaluation = true
        _on_game_tick_timeout()
        Task.print_behavior_tree_evaluation = false
    if Input.is_action_pressed("force_game_tick_fast"):
        _on_game_tick_timeout()
    if Input.is_action_just_pressed("toggle_temperature_layer"):
        toggle_temperature_layer()
        camera.print_config()
    if Input.is_action_just_pressed("auto_tick"):
        if game_ticker.is_stopped():
            game_ticker.start()
        else:
            game_ticker.stop()
    if Input.is_action_just_pressed("key_1"):
        get_tree().reload_current_scene()
    if Input.is_action_just_pressed("key_2"):
        player.exploration_task.current_goal = world.tilemap_ground.local_to_cell(world.get_local_mouse_position())
        player.behavior_tree.blackboard["cached_paths"] = {}
        player.behavior_tree.blackboard["path"] = []
    if Input.is_action_just_pressed("key_3"):
        player.board_position = Vector2i(world.camp_manager.camp)
        player.board_position.y += 1

    if intro_image.is_visible():
        intro_image.set_scale(calculate_scale(intro_image.texture.get_size()))


func calculate_scale(image_size: Vector2) -> Vector2:
    var viewport_size: Vector2 = world.get_viewport_rect().size
    var scale: float           = viewport_size.x / image_size.x
    return Vector2(scale, scale)


# SECTION: intro / outro

func set_intro_opacity(opacity: float) -> void:
    intro_image.set_modulate(Color(1, 1, 1, opacity))


func set_instructions_opacity(opacity: float) -> void:
    %InstructionsRect.set_modulate(Color(1, 1, 1, opacity))
    %InstructionsRect.show()


func set_outro_opacity(opacity: float) -> void:
    %OutroImageContainer.set_modulate(Color(1, 1, 1, opacity))
    %OutroImageContainer.show()


# SECTION: game tick

func player_health_depleted():
    # TODO
    pass


func _on_game_tick_timeout() -> void:
    var timer_on_game_tick_timeout: PerformanceTimer = PerformanceTimer.new()
    timer_on_game_tick_timeout.display_name = "frame"

    tilemap_navigation.game_tick_start()
    world.game_tick_start()

    player.game_tick()

    apply_player_exploration_distance()

    tree_visualizer.update_task_statuses(player.behavior_tree.blackboard)

    tilemap_navigation.game_tick_end()
    world.game_tick_end()
    EventsTracker.populate_visual_log(%RecentEventsLog, self)

    update_bars()
    world.camp_manager.populate_camp_visualization(%BoatProcessUI, %CampItemUI)
    handle_result_game_state(player.behavior_tree.blackboard)

    if not game_ticker.is_stopped():
        camera_follow_player()

    timer_on_game_tick_timeout.stop()


func camera_follow_player() -> void:
    var player_position: Vector2 = world.tilemap_player.cell_to_local(player.board_position)
    var targeted_position        = null

    if player.behavior_tree.blackboard.has("path"):
        var path: Array = player.behavior_tree.blackboard["path"]
        if path.size() > 0:
            targeted_position = world.tilemap_player.cell_to_local(path[path.size() - 1])

    if not targeted_position:
        camera.go_to(player_position)
        return

    var avg_position    = (player_position + targeted_position) / 2
    var distance: float = player_position.distance_to(targeted_position)
    var zoom_level: float
    if distance < 200:
        zoom_level = distance_to_zoom_level(200)
    else:
        zoom_level = distance_to_zoom_level(distance)

    avg_position.x += distance / 2

    camera.go_to_zooming(avg_position, zoom_level)


func apply_player_exploration_distance():
    player.exploration_task.closest_distance_to_goal = min(player.exploration_task.closest_distance_to_goal, TilemapNavigation.manhattan_distance(player.board_position, player.exploration_task.current_goal))


func distance_to_zoom_level(distance: float) -> float:
    var a: float = 862.08
    var b: float = 274.13
    return a / (distance + b)


func handle_result_game_state(blackboard: Dictionary) -> void:
    if blackboard.has("game_state_win"):
        EventsTracker.track(EventsTracker.Event.GAME_STATE_WIN)
        game_ticker.stop()
        get_tree().create_tween().tween_method(set_outro_opacity, 0.0, 1.0, 1.0)


func update_boat_progress_old() -> void:
    var part_counts: Dictionary = { # @formatter:off
        tilemap_types.OBJECT_I_BOAT_PART_ENGINE: 0,
        tilemap_types.OBJECT_I_BOAT_PART_FUEL: 0,
        tilemap_types.OBJECT_I_BOAT_PART_ANCHOR: 0,
        tilemap_types.OBJECT_I_BOAT_PART_CHEST: 0,
        tilemap_types.OBJECT_I_BOAT_PART_GEARS: 0,
        tilemap_types.OBJECT_I_BOAT_PART_MEDIKIT: 0,
        tilemap_types.OBJECT_I_BOAT_PART_PADDLE: 0,
        tilemap_types.OBJECT_I_BOAT_PART_GAS_STOVE: 0
    } # @formatter:on

    for boat_part in world.camp_manager.boat_items:
        if part_counts.has(boat_part):
            part_counts[boat_part] += 1

    for part in part_counts.keys():
        var count = part_counts[part]
        if count > 0:
            if part == tilemap_types.OBJECT_I_BOAT_PART_ENGINE:
                %BoatPartEngine.texture = world.tilemap_interactive.get_cell_texture(tilemap_types.OBJECT_I_BOAT_PART_ENGINE)
                %BoatPartEngine.visible = true
                %EngineCount.text = str(count)
            elif part == tilemap_types.OBJECT_I_BOAT_PART_FUEL:
                %BoatPartFuel.texture = world.tilemap_interactive.get_cell_texture(tilemap_types.OBJECT_I_BOAT_PART_FUEL)
                %BoatPartFuel.visible = true
                %FuelCount.text = str(count)
            elif part == tilemap_types.OBJECT_I_BOAT_PART_ANCHOR:
                %BoatPartAnchor.texture = world.tilemap_interactive.get_cell_texture(tilemap_types.OBJECT_I_BOAT_PART_ANCHOR)
                %BoatPartAnchor.visible = true
                %AnchorCount.text = str(count)
            elif part == tilemap_types.OBJECT_I_BOAT_PART_CHEST:
                %BoatPartChest.texture = world.tilemap_interactive.get_cell_texture(tilemap_types.OBJECT_I_BOAT_PART_CHEST)
                %BoatPartChest.visible = true
                %ChestCount.text = str(count)
            elif part == tilemap_types.OBJECT_I_BOAT_PART_GEARS:
                %BoatPartGears.texture = world.tilemap_interactive.get_cell_texture(tilemap_types.OBJECT_I_BOAT_PART_GEARS)
                %BoatPartGears.visible = true
                %GearsCount.text = str(count)
            elif part == tilemap_types.OBJECT_I_BOAT_PART_MEDIKIT:
                %BoatPartMedikit.texture = world.tilemap_interactive.get_cell_texture(tilemap_types.OBJECT_I_BOAT_PART_MEDIKIT)
                %BoatPartMedikit.visible = true
                %MedikitCount.text = str(count)
            elif part == tilemap_types.OBJECT_I_BOAT_PART_PADDLE:
                %BoatPartPaddle.texture = world.tilemap_interactive.get_cell_texture(tilemap_types.OBJECT_I_BOAT_PART_PADDLE)
                %BoatPartPaddle.visible = true
                %PaddleCount.text = str(count)
            elif part == tilemap_types.OBJECT_I_BOAT_PART_GAS_STOVE:
                %BoatPartGasStove.texture = world.tilemap_interactive.get_cell_texture(tilemap_types.OBJECT_I_BOAT_PART_GAS_STOVE)
                %BoatPartGasStove.visible = true
                %StoveCount.text = str(count)
            else:
                push_error("Unknown boat part: " + str(part))


func update_bars() -> void:
    if health_bar != null:
        health_bar.max_value = player.max_health
        health_bar.value = clamp(player.health, 0, player.max_health)
        %HealthLabel.text = str(health_bar.value) + "/" + str(player.max_health)
        %HealthLabel.add_theme_color_override("font_color", Color(1, 1, 1))

    if food_bar != null:
        food_bar.max_value = player.max_food
        food_bar.value = clamp(player.food, 0, player.max_food)
        %FoodLabel.text = str(food_bar.value) + "/" + str(player.max_food)

    if temperature_resistance_bar != null:
        temperature_resistance_bar.max_value = player.temperature_set_buff_value
        temperature_resistance_bar.value = clamp(player.temperature_buff_timer, 0, player.temperature_set_buff_value)
        %TemperatureResistanceLabel.text = str(temperature_resistance_bar.value) + "/" + str(player.temperature_set_buff_value)

    if temperature_bar != null:
        temperature_bar.max_value = player.temperature_endure
        # invert the value to show the time left
        var countdown: int = player.temperature_endure - player.temperature_timer
        temperature_bar.value = clamp(countdown, 0, player.temperature_endure)
        %TemperatureLabel.text = str(temperature_bar.value) + "/" + str(player.temperature_endure)

    if time_of_day_bar != null:
        time_of_day_bar.max_value = 1
        time_of_day_bar.value = float(world.camp_manager.time_of_day) / world.camp_manager.day_length
        time_of_day_bar.self_modulate = calculate_time_of_day_color(world.camp_manager.time_of_day, world.camp_manager.day_length)
        %TimeOfDayLabel.text = calculate_display_time_of_day(world.camp_manager.time_of_day, world.camp_manager.day_length)


func calculate_display_time_of_day(current_time: int, day_length: int) -> String:
    # format as 24 hour clock, start at 06:00 and end at 21:00
    var start: int         = 6
    var end: int           = 21
    var hours_per_day: int = end - start
    var time_of_day: float = float(current_time) / day_length * hours_per_day + start
    var hours: int         = int(time_of_day)
    var minutes: int       = int((time_of_day - hours) * 60)
    hours %= 24
    return str(hours).pad_zeros(2) + ":" + str(minutes).pad_zeros(2)


func calculate_time_of_day_color(current_time: int, day_length: int) -> Color:
    var start: Color    = Color(1, 1, 0)
    var end: Color      = Color(1, 0, 0)
    var progress: float = float(current_time) / day_length
    progress = clamp(progress, 0, 1)
    progress = pow(progress, 2)
    return start.lerp(end, progress)


func toggle_temperature_layer() -> void:
    world.tilemap_temperature.tilemap.visible = not world.tilemap_temperature.tilemap.visible


func wait_for_key_press():
    waiting_for_input = true
    while waiting_for_input:
        await get_tree().process_frame


func _input(event):
    if event is InputEventKey and event.pressed:
        waiting_for_input = false
