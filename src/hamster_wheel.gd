extends RigidBody2D


export var RAY_BASE_SIZE := 2.0
export var BASE_RADIUS := 3.0
export var BASE_IMPULSE := 50.0
export var BASE_JUMP_FORCE: float = 30.0
export var PER_HAMSTER_JUMP_FORCE: float = 1.5
## The multiplier of motion force when not touching the ground
export var AIR_MOTION_FACTOR := 0.4
export var JUMP_IMPULSE_DURATION_MS := 100.0

export var Hamster: PackedScene

onready var hamster_root: Node = $HamsterRoot

remote var p2_remote_x_input := 0.0
remote var p2_remote_jump_input := false

var left_action = "move_left"
var right_action = "move_right"
var jump_action = "move_up"

var is_p2_local = false

func _ready() -> void:
  rset_config("global_position", MultiplayerAPI.RPC_MODE_PUPPET)
  rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)

  $RayCast2D.set_as_toplevel(true)
  for _i in 10:
    add_hamster()

  var netCtx = get_node_or_null("/root/NetContext")
  if netCtx != null:
    var player_count = netCtx.connections.size()

    # disable the local second player (secondary set of inputs) if there is more than one player
    is_p2_local = player_count == 1

    if is_p2_local:
      left_action = "p2_move_left"
      right_action = "p2_move_right"
      jump_action = "p2_move_jump"


func add_hamster() -> void:
  var h := Hamster.instance()
  hamster_root.add_child(h)
  set_hamster_position()


func remove_hamster() -> void:
  var h := hamster_root.get_child(get_child_count() - 1)
  hamster_root.remove_child(h)
  h.queue_free()
  set_hamster_position()


func set_hamster_position() -> void:
  var hamster_count = hamster_root.get_child_count()
  for child in hamster_root.get_children():
    child.position = Vector2(BASE_RADIUS * (hamster_count - 1), 0).rotated((child.get_index() - 1.0) / hamster_count * (2 * PI))
    child.rotation = (child.get_index() - 1.0) / hamster_count * (2 * PI)


## convert a boolean to an int that can be added
static func boolscalar(b: bool) -> int:
  return 1 if b else 0

var jump_start_time = null

func _physics_process(delta: float) -> void:
  var touching_ground = $RayCast2D.is_colliding()
  var hamster_count = hamster_root.get_child_count()

  # handle left-right movement
  var p1_input = Input.get_axis("move_left", "move_right")
  var p2_input = Input.get_axis("p2_move_left", "p2_move_right") if is_p2_local else p2_remote_x_input
  var input := Vector2(p1_input + p2_input, 0)
  var air_touch_factor = 1.0 if touching_ground else AIR_MOTION_FACTOR
  apply_impulse(
    -input * BASE_RADIUS * (hamster_count - 1),
    input * air_touch_factor * BASE_IMPULSE * hamster_count * delta
  )

  # handle jump
  var jump_strength = (
    boolscalar(Input.is_action_pressed("move_up"))
    + boolscalar((is_p2_local and Input.is_action_pressed("p2_move_up")) or p2_remote_jump_input)
  )

  if touching_ground and jump_strength > 0 and jump_start_time == null:
    jump_start_time = OS.get_ticks_msec()
    if jump_strength == 1 and !$sfx_Jump_Single.is_playing():
      $sfx_Jump_Single.play()
    if jump_strength == 2 and !$sfx_Jump_Single.is_playing():
      $sfx_Jump_Double.play()
  if jump_start_time != null and OS.get_ticks_msec() - jump_start_time > JUMP_IMPULSE_DURATION_MS:
    jump_start_time = null

  if jump_start_time != null:
    apply_impulse(
      -Vector2.UP * BASE_RADIUS * (hamster_count - 1),
      Vector2.UP * jump_strength * (BASE_JUMP_FORCE + PER_HAMSTER_JUMP_FORCE * hamster_count)
    )
  $RayCast2D.position = position
  $RayCast2D.cast_to = Vector2(0, BASE_RADIUS * (hamster_count - 1) + RAY_BASE_SIZE)


func _process(_delta: float) -> void:
  if is_network_master():
    rset_unreliable("global_position", global_position)
    rset_unreliable("rotation", rotation)
  else:
    # NOTE: may want to do this on _input for less lag?
    rset_unreliable("p2_remote_x_input", Input.get_axis(left_action, right_action))
    rset_unreliable("p2_remote_jump_input", Input.is_action_pressed(jump_action))
