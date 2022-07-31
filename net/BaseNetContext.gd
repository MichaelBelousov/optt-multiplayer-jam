## node at /root/NetContext containing information about the current network connections when you are the host

extends Node

# random number under 2^16-1 and above like 2048 or somethin, I chose one I already have portforwarded
var port := 17451

## map to peer info by peer id
var connections := {}

func _ready() -> void:
  var local_id = get_tree().get_network_unique_id()
  # sample info for now, might need it later
  var local_info = {
    "EndName": "localhost",
  }
  connections[local_id] = local_info

  var new_peer = NetworkedMultiplayerENet.new();
  get_tree().network_peer = new_peer

  get_tree().connect("network_peer_connected", self, "network_peer_connected")
  get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")

remote func register(info: Dictionary) -> void:
  var peer_id = get_tree().get_rpc_sender_id()
  connections[peer_id] = info

func network_peer_connected(id: int) -> void:
  var local_id = get_tree().get_network_unique_id()
  var local_info = connections[local_id]
  rpc_id(id, "register", local_info)

func network_peer_disconnected(id: int) -> void:
  connections.erase(id)


