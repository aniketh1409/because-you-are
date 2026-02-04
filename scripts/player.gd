extends CharacterBody2D

@export var max_speed := 130.0
@export var accel := 700.0
@export var friction := 700.0

var can_move := true

func _physics_process(delta: float) -> void:
    if not can_move:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
        move_and_slide()
        return

    var input_dir := Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    )

    if input_dir.length() > 0:
        input_dir = input_dir.normalized()
        velocity = velocity.move_toward(input_dir * max_speed, accel * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

    move_and_slide()
