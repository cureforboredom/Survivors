extends AnimatableBody2D

class_name Enemy

@onready var poly = $Polygon2D
@onready var collider = $CollisionPolygon2D
@onready var hit_flash = $HitFlash

signal enemy_died

var targets = []
var speed = 80
var direction = PI / 2
var health = 5

func _ready() -> void:
  collider.polygon = poly.polygon
  
func _physics_process(delta: float) -> void:
  if health <= 0:
    enemy_died.emit()
    queue_free()
    
  var closest = null
  for target in targets:
    if is_instance_valid(target):
      if closest:
        if (position - target.position).length() < (position - closest).length():
          closest = target.position
      else:
        closest = target.position
    
  speed += 12 * delta
  direction = (position - closest).rotated(PI / 2).angle()
  position += Vector2(0, speed * delta).rotated(direction)
  
func hit():
  health -= 1
  hit_flash.visible = true
  var timer = get_tree().create_timer(0.1)
  await timer.timeout
  hit_flash.visible = false
