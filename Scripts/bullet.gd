extends Area2D

@onready var flash = $Flash
@onready var seeking = $Seeking

var direction = 0
var speed = 750

var nearby_enemies = []

func _ready() -> void:
  self.connect("body_entered", _on_body_entered)
  seeking.connect("body_entered", _on_seeking_entered)
  var flash_tween = get_tree().create_tween()
  flash_tween.tween_property(flash, "modulate", Color(1, 1, 1, 0), 0.02).set_delay(0.02)
  var bullet_tween = get_tree().create_tween()
  bullet_tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.65)
  await bullet_tween.finished
  self.queue_free()
  
func _physics_process(delta: float) -> void:
  if len(nearby_enemies) > 0:
    var closest_enemy = null
    for i in range(len(nearby_enemies) - 1, -1, -1):
      if !is_instance_valid(nearby_enemies[i]):
        nearby_enemies.remove_at(i)
      else:
        if !closest_enemy:
          closest_enemy = nearby_enemies[i]
        else:
          if (global_position - nearby_enemies[i].position).length() < (global_position - closest_enemy.position).length():
            closest_enemy = nearby_enemies[i]
    if is_instance_valid(closest_enemy):
      var new_direction = (closest_enemy.global_position - global_position).angle() + PI / 2
      direction = lerp_angle(direction, new_direction, 0.4)
        
  position += Vector2(speed * delta, 0).rotated(direction - PI / 2)
  
func _on_body_entered(body: Node2D):
  if body is Enemy:
    body.hit()
    queue_free()
    
func _on_seeking_entered(body: Node2D):
  if body is Enemy:
    nearby_enemies.append(body)
