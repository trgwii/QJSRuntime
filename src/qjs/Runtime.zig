const std = @import("std");
const c = @import("c.zig");
const malloc_functions = @import("malloc_functions.zig");
const Context = @import("Context.zig").Context;

pub fn Runtime(comptime RtState: type) type {
    return struct {
        ptr: *c.JSRuntime,

        const Self = @This();

        pub fn init(allocator: *const std.mem.Allocator) !Self {
            return .{
                .ptr = c.JS_NewRuntime2(
                    &malloc_functions.mf,
                    @constCast(allocator),
                ) orelse return error.OutOfMemory,
            };
        }

        pub fn setState(self: Self, state: *RtState) void {
            c.JS_SetRuntimeOpaque(self.ptr, state);
        }

        pub fn getState(self: Self) ?*RtState {
            return @as(?*RtState, c.JS_GetRuntimeOpaque(self.ptr));
        }

        pub fn deinit(self: Self) void {
            c.JS_FreeRuntime(self.ptr);
        }

        pub fn createContext(self: Self, comptime CtxState: type) !Context(RtState, CtxState) {
            return Context(RtState, CtxState).init(self.ptr);
        }

        // TODO: wrap the loader callback so it uses our Context type, maybe implement own JSModuleDef
        pub fn setModuleLoader(
            self: Self,
            comptime State: type,
            loader: *const fn (?*c.JSContext, path: ?[*:0]const u8, state: ?*anyopaque) callconv(.C) ?*c.JSModuleDef,
            state: *State,
        ) void {
            c.JS_SetModuleLoaderFunc(self.ptr, null, loader, state);
        }
    };
}
