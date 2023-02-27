const std = @import("std");
const c = @import("c.zig");
const Context = @import("Context.zig");
const RuntimeAllocator = @import("Runtime_allocator.zig");

allocator_state: RuntimeAllocator.AllocatorState,
ptr: *c.JSRuntime,

const Runtime = @This();
pub fn init(allocator: std.mem.Allocator) ?Runtime {
    var runtime = Runtime{
        .allocator_state = .{ .allocator = allocator },
        .ptr = undefined,
    };
    runtime.ptr = c.JS_NewRuntime2(&RuntimeAllocator.js_malloc_functions, &runtime.allocator_state);

    return runtime;
}

pub fn destroy(self: Runtime) void {
    c.JS_FreeRuntime(self.ptr);
}

pub fn createContext(self: Runtime) ?Context {
    return .{ .ptr = c.JS_NewContext(self.ptr) orelse return null };
}
