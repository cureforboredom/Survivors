extends Area2D

@onready var flash = $Flash

var direction = 0

func _ready() -> void:
  self.connect("body_entered", _on_body_entered)
  var flash_tween = get_tree().create_tween()
  flash_tween.tween_property(flash, "modulate", Color(1, 1, 1, 0), 0.02).set_delay(0.02)
  var bullet_tween = get_tree().create_tween()
  bullet_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.65)
  await bullet_tween.finished
  self.queue_free()
  
func _physics_process(delta: float) -> void:
  position += Vector2(0, -650 * delta).rotated(direction)
  
func _on_body_entered(body: Node2D):
  if body is Enemy:
    body.hit()
    queue_free()