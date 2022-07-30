extends Panel

func _ready():
  setup_get_public_ip()

func setup_get_public_ip():
  var req = HTTPRequest.new()
  add_child(req)
  req.connect("request_completed", self, "on_public_ip_resp")
  var err = req.request("https://api.ipify.org")
  #if err != OK:
   # push_error("An error occurred in the HTTP request.")

func on_public_ip_resp(_result, _response_code, _headers, body):
  var public_ip = body.get_string_from_utf8()
  $VBoxContainer/IPInput.text = public_ip


func on_host():
  $AudioStreamPlayer.play()  
  var HostNetContext = preload("res://net/HostNetContext.gd")
  var netCtx = HostNetContext.new()
  netCtx.name = "NetContext"
  get_tree().root.add_child(netCtx)
  


func on_join():
  $AudioStreamPlayer.play()  
  var ClientNetContext = preload("res://net/ClientNetContext.gd")
  var netCtx = ClientNetContext.new()
  netCtx.name = "NetContext"
  get_tree().root.add_child(netCtx)
  
