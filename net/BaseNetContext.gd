## node at /root/NetContext containing information about the current network connections when you are the host

extends Node

# random number under 2^16-1 and above like 2048 or somethin, I chose one I already have portforwarded
var port := 17451

## map to peer info by peer id
var connections := {}

func _ready() -> void:
  get_tree().connect("network_peer_connected", self, "network_peer_connected")
  get_tree().connect("network_peer_disconnected", self, "network_peer_disconnected")

  var new_peer = NetworkedMultiplayerENet.new();
  init_peer(new_peer)
  get_tree().network_peer = new_peer

  var local_id = get_tree().get_network_unique_id()
  # sample info for now, might need it later
  var local_info = {
    "EndName": "localhost",
  }
  connections[local_id] = local_info

## must be overridden to put peer in connecting state, e.g. call create_client or create_server
## otherwise assigning it to get_tree().network_peer will fail in the disconnected state
func init_peer(_peer: NetworkedMultiplayerENet) -> void:
  assert(false, "must be overridden")

remote func register(info: Dictionary) -> void:
  var peer_id = get_tree().get_rpc_sender_id()
  connections[peer_id] = info

  # HACK: bad way of accessing the connected_player_count state
  var cur_scene = get_tree().get_current_scene()
  if cur_scene.has_method("set_connected_player_count"):
    var connected_player_count = connections.size() - 1
    cur_scene.set_connected_player_count(connected_player_count)


func network_peer_connected(id: int) -> void:
  var local_id = get_tree().get_network_unique_id()
  var local_info = connections[local_id]
  rpc_id(id, "register", local_info)

func network_peer_disconnected(id: int) -> void:
  connections.erase(id)


