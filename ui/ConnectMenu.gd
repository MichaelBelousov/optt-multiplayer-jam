extends Panel

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


func on_join() -> void:
  $AudioStreamPlayer.play()
  var ClientNetContext = preload("res://net/ClientNetContext.gd")
  var addr = $VBoxContainer/IPInput.text
  var netCtx = ClientNetContext.new(addr)
  netCtx.name = "NetContext"
  get_tree().root.add_child(netCtx)
