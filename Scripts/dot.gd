extends Sprite2D

func _ready() -> void:
  var tween = get_tree().create_tween()
  tween.tween_property(self, "self_modulate", Color(1,1,1,0), 1)
  await tween.finished
  self.queue_free()
