
extends Panel

var connected_player_count: int = 0 setget set_connected_player_count
var player_count_label: Label = null

onready var generic_opts: VBoxContainer = $Tabs/Options
onready var connection_opts: VBoxContainer = $Tabs/Connection

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
  print(connection_opts)
  connection_opts.get_node("Center/Btns/Host").disabled = false
  connection_opts.get_node("IPInput").text = public_ip


func on_host() -> void:
  $UIClick.play()
  var ServerNetContext = preload("res://net/ServerNetContext.gd")
  var netCtx = ServerNetContext.new()
  netCtx.name = "NetContext"
  get_tree().root.add_child(netCtx)
  setup_host_ui()


func on_join() -> void:
  $UIClick.play()
  var ClientNetContext = preload("res://net/ClientNetContext.gd")
  var addr = connection_opts.get_node("IPInput").text
  var netCtx = ClientNetContext.new(addr)
  netCtx.name = "NetContext"
  get_tree().root.add_child(netCtx)
  setup_join_ui()


# NOTE: could be done better by instancing a scene to replace `Btns`
func setup_host_ui() -> void:
  connection_opts.get_node("IPInput").editable = false
  connection_opts.get_node("Center/Btns/Host").visible = false
  connection_opts.get_node("Center/Btns/Join").visible = false
  var start = Button.new()
  start.text = "Start"
  start.connect("pressed", self, "on_start_pressed")
  connection_opts.get_node("Center/Btns").add_child(start)
  player_count_label = Label.new()
  self.connected_player_count = 0  # need `self` to invoke setter
  connection_opts.get_node("Center/Btns").add_child(player_count_label)

var join_info_label = null

# NOTE: could be done better by instancing a scene to replace `Btns`
func setup_join_ui() -> void:
  connection_opts.get_node("IPInput").editable = false
  connection_opts.get_node("Center/Btns/Host").visible = false
  connection_opts.get_node("Center/Btns/Join").visible = false
  get_tree().connect("connected_to_server", self, "on_client_connected")
  join_info_label = Label.new()
  join_info_label.text = "Connecting..."
  connection_opts.get_node("Center/Btns").add_child(join_info_label)


func on_client_connected():
  join_info_label.text = "Please wait for the host to start the game"


func on_start_pressed() -> void:
	$UIClick.play()
	yield($UIClick, "Finished")  
	rpc("start")


# NOTE: possible we'll need to add a wait step on some synchronization due to lag, we'll see...
remotesync func start() -> void:
  var main_scene = preload("res://src/test.tscn")
  assert(OK == get_tree().change_scene_to(main_scene), "couldn't start the main scene")
  # potentially might fix desync issues by waiting here


const MASTER_BUS_INDEX = 0
const BGMUSIC_BUS_INDEX = 1
const SFX_BUS_INDEX = 2



func on_toggle_music_on(button_pressed: bool) -> void:
  $UIBackClick.play()
  AudioServer.set_bus_mute(BGMUSIC_BUS_INDEX, not button_pressed)


func on_toggle_sfx_on(button_pressed: bool) -> void:
  AudioServer.set_bus_mute(SFX_BUS_INDEX, not button_pressed)
  #if button_up():
   # $UIClick.play()


