extends Node2D

const HamsterWheel = preload("res://src/hamster_wheel.gd")

func on_area_entered(body: Node) -> void:
  if body is HamsterWheel:
    body.add_hamster()
    queue_free()
    $sfx_Gain_Hamster.play()


