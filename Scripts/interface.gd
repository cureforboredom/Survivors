extends Interface

@onready var dots = preload("res://Scenes/dot.tscn")

func _ready() -> void:
  self.create_room()

func _process(_delta: float) -> void:
  var msg = [""]
  var msgs = []
  while !["None", "Closed"].has(msg[0]):
    if !msg[0].is_empty():
      msgs.append(msg)
    msg = self.receive()

  for m in msgs:
    if m[0] == "click":
      var dot = dots.instantiate()
      dot.position = Vector2(m[1][0], m[1][1])
      get_tree().root.add_child(dot)

  if Input.is_action_just_pressed("mouse_left_click"):
    var mouse_pos = get_viewport().get_mouse_position()
    self.send("click", [mouse_pos.x, mouse_pos.y])
