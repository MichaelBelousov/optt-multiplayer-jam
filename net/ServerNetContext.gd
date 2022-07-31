
extends "res://net/BaseNetContext.gd"

const PLAYER_LIMIT := 2

func _ready() -> void:
  ._ready()
  # base must have already set up network_peer
  get_tree().network_peer.create_server(port, PLAYER_LIMIT)

func on_connected_to_server() -> void:
  pass

func on_server_connection_failure() -> void:
  assert(false, "failed to connect")

func on_server_disconnected() -> void:
  assert(false, "server disconnected")