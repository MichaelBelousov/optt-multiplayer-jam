
extends "res://net/BaseNetContext.gd"

var _address := ""

func _init(addr: String) -> void:
  _address = addr

func _ready() -> void:
  ._ready()
  get_tree().connect("connected_to_server", self, "on_connected_to_server");
  get_tree().connect("connection_failed", self, "on_server_connection_failure");
  get_tree().connect("server_disconnected", self, "on_server_disconnected");
  # base must have already set up network_peer
  get_tree().network_peer.create_client(_address, port)

func on_connected_to_server() -> void:
  pass

func on_server_connection_failure() -> void:
  assert(false, "failed to connect")

func on_server_disconnected() -> void:
  assert(false, "server disconnected")