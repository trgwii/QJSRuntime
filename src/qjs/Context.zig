const c = @import("c.zig");

ptr: *c.JSContext,

const Context = @This();

pub fn deinit(self: Context) void {
    c.JS_FreeContext(self.ptr);
}
