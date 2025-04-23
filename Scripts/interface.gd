extends Interface

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
