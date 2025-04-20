extends Interface

@onready var dots = preload("res://Scenes/dot.tscn")

var joined_room = false

func _ready() -> void:
  self.join_room("CgAOzKf2")

func _process(_delta: float) -> void:
  var msg = ["",""]
  var msgs = []
  while !["None", "Closed"].has(msg[1]):
    if !msg[1].is_empty():
      msgs.append(msg)
    msg = self.receive()

  for m in msgs:
    if !joined_room and m[1] == "join" and m[0] == self.get_id():
      if m[2][0] == 1.0:
        joined_room = true
        print("joined room")

    if m[1] == "click":
      var dot = dots.instantiate()
      dot.position = Vector2(m[2][0], m[2][1])
      get_tree().root.add_child(dot)

  if Input.is_action_just_pressed("mouse_left_click"):
    var mouse_pos = get_viewport().get_mouse_position()
    self.send("click", [mouse_pos.x, mouse_pos.y])
