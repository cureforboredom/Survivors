// THIS FILE IS AUTOMATICALLY GENERATED BY SPACETIMEDB. EDITS TO THIS FILE
// WILL NOT BE SAVED. MODIFY TABLES IN YOUR MODULE SOURCE CODE INSTEAD.

#![allow(unused, clippy::all)]
use spacetimedb_sdk::__codegen::{self as __sdk, __lib, __sats, __ws};

#[derive(__lib::ser::Serialize, __lib::de::Deserialize, Clone, PartialEq, Debug)]
#[sats(crate = __lib)]
pub(super) struct JoinRoomArgs {
    pub room_key: String,
}

impl From<JoinRoomArgs> for super::Reducer {
    fn from(args: JoinRoomArgs) -> Self {
        Self::JoinRoom {
            room_key: args.room_key,
        }
    }
}

impl __sdk::InModule for JoinRoomArgs {
    type Module = super::RemoteModule;
}

pub struct JoinRoomCallbackId(__sdk::CallbackId);

#[allow(non_camel_case_types)]
/// Extension trait for access to the reducer `join_room`.
///
/// Implemented for [`super::RemoteReducers`].
pub trait join_room {
    /// Request that the remote module invoke the reducer `join_room` to run as soon as possible.
    ///
    /// This method returns immediately, and errors only if we are unable to send the request.
    /// The reducer will run asynchronously in the future,
    ///  and its status can be observed by listening for [`Self::on_join_room`] callbacks.
    fn join_room(&self, room_key: String) -> __sdk::Result<()>;
    /// Register a callback to run whenever we are notified of an invocation of the reducer `join_room`.
    ///
    /// Callbacks should inspect the [`__sdk::ReducerEvent`] contained in the [`super::ReducerEventContext`]
    /// to determine the reducer's status.
    ///
    /// The returned [`JoinRoomCallbackId`] can be passed to [`Self::remove_on_join_room`]
    /// to cancel the callback.
    fn on_join_room(
        &self,
        callback: impl FnMut(&super::ReducerEventContext, &String) + Send + 'static,
    ) -> JoinRoomCallbackId;
    /// Cancel a callback previously registered by [`Self::on_join_room`],
    /// causing it not to run in the future.
    fn remove_on_join_room(&self, callback: JoinRoomCallbackId);
}

impl join_room for super::RemoteReducers {
    fn join_room(&self, room_key: String) -> __sdk::Result<()> {
        self.imp
            .call_reducer("join_room", JoinRoomArgs { room_key })
    }
    fn on_join_room(
        &self,
        mut callback: impl FnMut(&super::ReducerEventContext, &String) + Send + 'static,
    ) -> JoinRoomCallbackId {
        JoinRoomCallbackId(self.imp.on_reducer(
            "join_room",
            Box::new(move |ctx: &super::ReducerEventContext| {
                let super::ReducerEventContext {
                    event:
                        __sdk::ReducerEvent {
                            reducer: super::Reducer::JoinRoom { room_key },
                            ..
                        },
                    ..
                } = ctx
                else {
                    unreachable!()
                };
                callback(ctx, room_key)
            }),
        ))
    }
    fn remove_on_join_room(&self, callback: JoinRoomCallbackId) {
        self.imp.remove_on_reducer("join_room", callback.0)
    }
}

#[allow(non_camel_case_types)]
#[doc(hidden)]
/// Extension trait for setting the call-flags for the reducer `join_room`.
///
/// Implemented for [`super::SetReducerFlags`].
///
/// This type is currently unstable and may be removed without a major version bump.
pub trait set_flags_for_join_room {
    /// Set the call-reducer flags for the reducer `join_room` to `flags`.
    ///
    /// This type is currently unstable and may be removed without a major version bump.
    fn join_room(&self, flags: __ws::CallReducerFlags);
}

impl set_flags_for_join_room for super::SetReducerFlags {
    fn join_room(&self, flags: __ws::CallReducerFlags) {
        self.imp.set_call_reducer_flags("join_room", flags);
    }
}
