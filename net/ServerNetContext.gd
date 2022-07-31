
extends "res://net/BaseNetContext.gd"

const PLAYER_LIMIT := 2

func init_peer(peer: NetworkedMultiplayerENet) -> void:
  var stat = peer.create_server(port, PLAYER_LIMIT)
  assert(stat == OK, "expected creating a server to work")
