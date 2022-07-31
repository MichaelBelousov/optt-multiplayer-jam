extends RigidBody2D


export var BASE_RADIUS := 3.0
export var BASE_IMPULSE := 50.0
export var JUMP_FORCE := 1.0

export var Hamster: PackedScene

remote var p2_x_input := 0.0
remote var p2_space_state := false

func _ready() -> void:
	rset_config("global_position", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)

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
	# TODO: duplicate input values by synchronized input of other player(s)
	var p1_input = Input.get_axis("move_left", "move_right")
	var input := Vector2(p1_input + p2_x_input, 0)
	apply_impulse(-input * BASE_RADIUS * (get_child_count() - 3), input * BASE_IMPULSE * (get_child_count() - 2) * delta)
	var is_jump_pressed = Input.is_action_pressed("move_up") or p2_space_state
	if is_jump_pressed and $RayCast2D.is_colliding():
		apply_impulse(-Vector2.UP * BASE_RADIUS * (get_child_count() - 3), Vector2.UP * JUMP_FORCE * (get_child_count() - 2))
	$RayCast2D.position = position
	$RayCast2D.cast_to = Vector2(0, BASE_RADIUS * (get_child_count() - 3) + 64)


func _process(_delta: float) -> void:
	if is_network_master():
		rset_unreliable("global_position", global_position)
		rset_unreliable("rotation", rotation)
	else:
		# NOTE: may want to do this on _input for less lag?
	  rset_unreliable("p2_x_input", Input.get_axis("p2_move_left", "p2_move_right"))
	  rset_unreliable("p2_space_state", Input.is_action_pressed("p2_move_up"))
