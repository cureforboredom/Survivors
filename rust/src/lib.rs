use std::sync::mpsc::channel;
use std::sync::mpsc::Receiver;
use std::sync::mpsc::TryRecvError;

use godot::classes::INode;
use godot::classes::Node;
use godot::prelude::*;

use spacetimedb_sdk::DbContext;
use spacetimedb_sdk::Event;
use spacetimedb_sdk::Table;

mod module_bindings;
use module_bindings::*;

const HOST: &str = "https://maincloud.spacetimedb.com";
const DB_NAME: &str = "c20090aef116d36e131c824df8d418c0bad5f42f954167f5fa893895e77fc7bd";

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
            .on_connect_error(|_ctx, err| eprintln!("Connection error: {:?}", err))
            .on_disconnect(|_ctx, err| {
                if let Some(err) = err {
                    eprintln!("Disconnected: {}", err);
                }
            })
            .with_module_name(DB_NAME)
            .with_uri(HOST)
            .build()
            .expect("Failed to connect");

        let sender_clone = sender.clone();
        ctx.db.message().on_insert(move |ctx, message| {
            if let Event::Reducer(_) = ctx.event {
                if message.sender != ctx.identity() {
                    sender_clone.send(message.clone()).unwrap_or_default();
                }
            }
        });

        // let sender_clone = sender.clone();
        ctx.subscription_builder()
            // .on_applied(move |ctx| {
            //     let mut messages = ctx
            //         .db
            //         .message()
            //         .iter()
            //         .filter(|m| m.sender != ctx.identity())
            //         .collect::<Vec<_>>();
            //     messages.sort_by_key(|m| m.sent);
            //     for message in messages {
            //         sender_clone.send(message.clone()).unwrap_or_default();
            //     }
            // })
            .subscribe(["SELECT * FROM message"]);

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
            return varray!["None".to_string(), vec![0.0; 0]];
        } else if message
            .clone()
            .is_err_and(|x| x == TryRecvError::Disconnected)
        {
            return varray!["Closed".to_string(), vec![0.0; 0]];
        }
        let message = message.unwrap();
        varray![message.kind, message.data.unwrap_or(vec![0.0; 0])]
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
}
