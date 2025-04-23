use std::sync::mpsc::channel;
use std::sync::mpsc::Receiver;
use std::sync::mpsc::TryRecvError;

use std::fs;

use const_format::concatcp;

use godot::classes::INode;
use godot::classes::Node;
use godot::prelude::*;

use spacetimedb_sdk::DbContext;
use spacetimedb_sdk::Event;
use spacetimedb_sdk::Status;
use spacetimedb_sdk::Table;

mod module_bindings;
use module_bindings::*;

const HOST: &str = "https://maincloud.spacetimedb.com";
const DB_NAME: &str = "c20090aef116d36e131c824df8d418c0bad5f42f954167f5fa893895e77fc7bd";
const TOKEN_FILE: &str = &concatcp!("./" , DB_NAME , ".token");

struct Extension;

#[gdextension]
unsafe impl ExtensionLibrary for Extension {}

#[derive(GodotClass)]
#[class(base=Node)]
struct Interface {
    ctx: DbConnection,
    receiver: Receiver<Message>,
    base: Base<Node>,
}

#[godot_api]
impl INode for Interface {
    fn init(base: Base<Node>) -> Self {
        let (sender, receiver) = channel::<Message>();

        let ctx = DbConnection::builder()
            .on_connect(|_ctx, _identity, token| {
                fs::write(TOKEN_FILE, token).unwrap_or_default();
            })
            .on_connect_error(|_ctx, err| eprintln!("Connection error: {:?}", err))
            .on_disconnect(|_ctx, err| {
                if let Some(err) = err {
                    eprintln!("Disconnected: {}", err);
                }
            })
            .with_token(fs::read_to_string(TOKEN_FILE).ok())
            .with_module_name(DB_NAME)
            .with_uri(HOST)
            .build()
            .expect("Failed to connect");

        let sender_clone = sender.clone();
        ctx.db.message().on_insert(move |ctx, message| {
            if let Event::Reducer(_) = ctx.event {
                if let Some(user) = ctx.db.user().identity().find(&ctx.identity()) {
                    if (!user.room.is_none()
                        && message.sender != ctx.identity()
                        && message.room == user.room.unwrap())
                        || (message.kind == "join".to_string() && message.sender == ctx.identity())
                    {
                        sender_clone.send(message.clone()).unwrap_or_default();
                    }
                }
            }
        });

        ctx.reducers.on_join_room(|ctx, _| {
            if let Status::Failed(_) = ctx.event.status {
                ctx.reducers
                    .send_message("join".to_string(), Some(vec![0.0]))
                    .unwrap_or_default();
            } else {
                ctx.reducers
                    .send_message("join".to_string(), Some(vec![1.0]))
                    .unwrap_or_default();
            }
        });

        ctx.subscription_builder()
            .subscribe(["SELECT * FROM message", "SELECT * FROM user"]);

        ctx.run_threaded();

        Self {
            ctx,
            receiver,
            base,
        }
    }
}

#[godot_api]
impl Interface {
    #[func]
    fn receive(&mut self) -> Array<Variant> {
        let message = self.receiver.try_recv();
        if message.clone().is_err_and(|x| x == TryRecvError::Empty) {
            return varray!["".to_string(), "None".to_string(), vec![0.0; 0]];
        } else if message
            .clone()
            .is_err_and(|x| x == TryRecvError::Disconnected)
        {
            return varray!["".to_string(), "Closed".to_string(), vec![0.0; 0]];
        }
        let message = message.unwrap();
        varray![
            message.sender.to_string(),
            message.kind,
            message.data.unwrap_or(vec![0.0; 0])
        ]
    }

    #[func]
    fn send(&mut self, kind: String, data: Vec<f64>) {
        self.ctx
            .reducers
            .send_message(kind, Some(data))
            .unwrap_or_default();
    }

    #[func]
    fn create_room(&mut self) {
        self.ctx.reducers.create_room().unwrap_or_default();
    }

    #[func]
    fn join_room(&mut self, key: String) {
        self.ctx.reducers.join_room(key).unwrap_or_default();
    }

    #[func]
    fn get_id(&mut self) -> String {
        self.ctx.identity().to_string()
    }
}
