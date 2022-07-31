
extends Panel

var connected_player_count: int = 0 setget set_connected_player_count
var player_count_label: Label = null

func set_connected_player_count(val: int) -> void:
  connected_player_count = val
  if player_count_label != null:
    player_count_label.text = "Connected players: " + str(val)


func _ready() -> void:
  setup_get_public_ip()


func setup_get_public_ip() -> void:
  var req = HTTPRequest.new()
  add_child(req)
  req.connect("request_completed", self, "on_public_ip_resp")
  var err = req.request("https://api.ipify.org")
  if err != OK:
    push_error("An error occurred in the HTTP request.")


func on_public_ip_resp(_result, _response_code, _headers, body) -> void:
  var public_ip = body.get_string_from_utf8()
  $VBoxContainer/Center/Btns/Host.disabled = false
  $VBoxContainer/IPInput.text = public_ip


func on_host() -> void:
  $AudioStreamPlayer.play()
  var ServerNetContext = preload("res://net/ServerNetContext.gd")
  var netCtx = ServerNetContext.new()
  netCtx.name = "NetContext"
  get_tree().root.add_child(netCtx)
  setup_host_ui()


func on_join() -> void:
  $AudioStreamPlayer.play()
  var ClientNetContext = preload("res://net/ClientNetContext.gd")
  var addr = $VBoxContainer/IPInput.text
  var netCtx = ClientNetContext.new(addr)
  netCtx.name = "NetContext"
  get_tree().root.add_child(netCtx)
  setup_join_ui()


# NOTE: could be done better by instancing a scene to replace `Btns`
func setup_host_ui() -> void:
  $VBoxContainer/IPInput.editable = false
  $VBoxContainer/Center/Btns/Host.visible = false
  $VBoxContainer/Center/Btns/Join.visible = false
  var start = Button.new()
  start.text = "Start"
  start.connect("pressed", self, "on_start_pressed")
  $VBoxContainer/Center/Btns.add_child(start)
  player_count_label = Label.new()
  self.connected_player_count = 0  # need `self` to invoke setter
  $VBoxContainer/Center/Btns.add_child(player_count_label)


# NOTE: could be done better by instancing a scene to replace `Btns`
func setup_join_ui() -> void:
  $VBoxContainer/IPInput.editable = false
  $VBoxContainer/Center/Btns/Host.visible = false
  $VBoxContainer/Center/Btns/Join.visible = false
  var instr = Label.new()
  instr.text = "Please wait for the host to start the game"
  $VBoxContainer/Center/Btns.add_child(instr)


func on_start_pressed() -> void:
  rpc("start")


# NOTE: possible we'll need to add a wait step on some synchronization due to lag, we'll see...
remotesync func start() -> void:
  var main_scene = preload("res://src/test.tscn")
  assert(OK == get_tree().change_scene_to(main_scene), "couldn't start the main scene")
  # potentially might fix desync issues by waiting here
