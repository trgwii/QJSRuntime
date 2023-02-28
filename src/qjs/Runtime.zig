const std = @import("std");
const c = @import("c.zig");
const types = @import("types.zig");
const Context = @import("Context.zig").Context;
const RuntimeAllocator = @import("Runtime_allocator.zig");

pub fn Runtime(comptime T: type) type {
    return struct {
        allocator_state: RuntimeAllocator.AllocatorState,
        ptr: *types.JSRuntime,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) ?Self {
            var runtime = Self{
                .allocator_state = .{ .allocator = allocator },
                .ptr = undefined,
            };

            // TODO: handle unreachable
            runtime.ptr = c.JS_NewRuntime2(&RuntimeAllocator.js_malloc_functions, &runtime.allocator_state) orelse unreachable;

            return runtime;
        }

        pub fn setState(self: Self, state: T) void {
            c.JS_SetRuntimeOpaque(self.ptr, state);
        }

        pub fn getState(self: Self) ?T {
            return @as(T, c.JS_GetRuntimeOpaque(self.ptr));
        }

        pub fn deinit(self: Self) void {
            c.JS_FreeRuntime(self.ptr);
        }

        pub fn createContext(self: Self) ?Context(T) {
            return Context(T).init(self.ptr);
        }

        pub fn setModuleLoader(self: Self, comptime module_normalize: ?*const c.JSModuleNormalizeFunc, comptime module_loader: ?*const c.JSModuleLoaderFunc, extra: ?*anyopaque) void {
            return c.JS_SetModuleLoaderFunc(self.ptr, module_normalize, module_loader, extra);
        }
    };
}
