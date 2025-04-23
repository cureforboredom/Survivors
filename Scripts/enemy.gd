extends AnimatableBody2D

class_name Enemy

@onready var poly = $Polygon2D
@onready var collider = $CollisionPolygon2D
@onready var hit_flash = $HitFlash

var targets = []
var speed = 80
var health = 5

func _ready() -> void:
  collider.polygon = poly.polygon
  
func _physics_process(delta: float) -> void:
  if health <= 0:
    queue_free()
    
  var closest = targets[0]
  for target in targets:
    if (position - target.position).length() < (position - closest.position).length():
      closest = target
    
  speed += 15 * delta
  var direction = (position - closest.position).rotated(PI / 2).angle()
  position += Vector2(0, speed * delta).rotated(direction)
  
func hit():
  health -= 1
  hit_flash.visible = true
  var timer = get_tree().create_timer(0.1)
  await timer.timeout
  hit_flash.visible = false