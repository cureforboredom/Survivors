use spacetimedb::rand::distributions::Alphanumeric;
use spacetimedb::rand::Rng;
use spacetimedb::{reducer, table, Identity, ReducerContext, Table, Timestamp};

#[table(name = user)]
pub struct User {
    #[primary_key]
    identity: Identity,
    name: Option<String>,
    room: Option<u64>,
    online: bool,
}

#[table(name = room)]
pub struct Room {
    #[primary_key]
    #[auto_inc]
    id: u64,
    #[unique]
    #[index(btree)]
    key: String,
}

#[table(name = message, public)]
pub struct Message {
    #[primary_key]
    #[auto_inc]
    id: u64,
    sender: Identity,
    #[index(btree)]
    room: u64,
    sent: Timestamp,
    kind: String,
    data: Option<Vec<f64>>,
}

#[reducer]
pub fn create_room(ctx: &ReducerContext) -> Result<(), String> {
    if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        let room = loop {
            let room_key = ctx
                .rng()
                .sample_iter(Alphanumeric)
                .take(8)
                .map(char::from)
                .collect();
            let room = ctx.db.room().try_insert(Room {
                id: 0,
                key: room_key,
            });
            if room.is_ok() {
                break room.unwrap();
            }
        };
        ctx.db.user().identity().update(User {
            room: Some(room.id),
            ..user
        });
        Ok(())
    } else {
        Err("Unknown user".to_string())
    }
}

#[reducer]
pub fn join_room(ctx: &ReducerContext, room_key: String) -> Result<(), String> {
    if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        if let Some(room) = ctx.db.room().key().find(room_key.clone()) {
            log::info!("joining room with key: {}", room_key.clone());
            let r = ctx.db.user().identity().update(User {
                room: Some(room.id),
                ..user
            });
            log::info!("{:?}: {:?}", r.name, r.room);
            Ok(())
        } else {
            log::info!("Room key is not valid");
            Err("Room key is not valid".to_string())
        }
    } else {
        log::info!("Unknown user");
        Err("Unknown user".to_string())
    }
}

#[reducer]
pub fn set_name(ctx: &ReducerContext, name: String) -> Result<(), String> {
    if name.is_empty() {
        log::info!("Names cannot be empty");
        Err("Names cannot be empty".to_string())
    } else if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        log::info!("Setting name to {}", name.clone());
        let r = ctx.db.user().identity().update(User {
            name: Some(name.clone()),
            ..user
        });
        log::info!("new name: {}", r.name.unwrap());
        Ok(())
    } else {
        log::info!("Cannot set name for unknown user");
        Err("Cannot set name for unknown user".to_string())
    }
}

#[reducer]
pub fn send_message(
    ctx: &ReducerContext,
    kind: String,
    data: Option<Vec<f64>>,
) -> Result<(), String> {
    if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        if user.room.is_some() {
            ctx.db.message().insert(Message {
                id: 0,
                sender: ctx.sender,
                room: user.room.unwrap(),
                sent: ctx.timestamp,
                kind: kind,
                data: data,
            });
            Ok(())
        } else {
            Err("User not in a room".to_string())
        }
    } else {
        Err("Unknown user".to_string())
    }
}

#[reducer(client_connected)]
pub fn client_connected(ctx: &ReducerContext) {
    if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        log::info!("user exists, setting online to true");
        ctx.db.user().identity().update(User {
            online: true,
            //room: None,
            ..user
        });
    } else {
        log::info!("user doesn't exist, setting online to true");
        ctx.db.user().insert(User {
            identity: ctx.sender,
            online: true,
            name: None,
            room: None,
        });
    }
}

#[reducer(client_disconnected)]
pub fn client_disconnected(ctx: &ReducerContext) {
    if let Some(user) = ctx.db.user().identity().find(ctx.sender) {
        ctx.db.user().identity().update(User {
            online: false,
            //room: None,
            ..user
        });
    } else {
        log::warn!(
            "Disconnect event for unknown user with identity {:?}",
            ctx.sender
        );
    }
}
