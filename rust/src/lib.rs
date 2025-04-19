use godot::prelude::*;
use godot::classes::Node;
use godot::classes::INode;

struct Extension;

#[gdextension]
unsafe impl ExtensionLibrary for Extension {}

#[derive(GodotClass)]
#[class(base=Node)]
struct Interface {
    base: Base<Node>
}

#[godot_api]
impl INode for Interface {
    fn init(base: Base<Node>) -> Self {
        Self {
            base
        }
    }
}