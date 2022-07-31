extends RigidBody2D


export var BASE_RADIUS := 3.0
export var BASE_IMPULSE := 50.0
export var JUMP_FORCE := 1.0

export var Hamster: PackedScene


func _ready() -> void:
	$RayCast2D.set_as_toplevel(true)
	for _i in 10:
		add_hamster()


func add_hamster() -> void:
	var h := Hamster.instance()
	add_child(h)
	set_hamster_position()


func remove_hamster() -> void:
	var h := get_child(get_child_count() - 1)
	remove_child(h)
	h.queue_free()
	set_hamster_position()


func set_hamster_position() -> void:
	for child in get_children():
		if not child is CollisionShape2D:
			continue
		child.position = Vector2(BASE_RADIUS * (get_child_count() - 3), 0).rotated((child.get_index() - 1.0) / (get_child_count() - 2) * (2 * PI))
		child.rotation = (child.get_index() - 1.0) / (get_child_count() - 2) * (2 * PI)


func _physics_process(delta: float) -> void:
	var input := Vector2(Input.get_axis("move_left", "move_right"), 0)
	apply_impulse(-input * BASE_RADIUS * (get_child_count() - 3), input * BASE_IMPULSE * (get_child_count() - 2) * delta)
	if Input.is_action_pressed("move_up") and $RayCast2D.is_colliding():
		apply_impulse(-Vector2.UP * BASE_RADIUS * (get_child_count() - 3), Vector2.UP * JUMP_FORCE * (get_child_count() - 2))
	$RayCast2D.position = position
	$RayCast2D.cast_to = Vector2(0, BASE_RADIUS * (get_child_count() - 3) + 64)
