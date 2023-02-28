const c = @import("c.zig");
const Runtime = @import("Runtime.zig").Runtime;
const Enums = @import("enums.zig");
const types = @import("types.zig");

pub fn Context(comptime T: type) type {
    return struct {
        ptr: *c.JSContext,

        const Self = @This();

        pub fn init(runtime: *types.JSRuntime) ?Self {
            return .{ .ptr = c.JS_NewContext(runtime) orelse return null };
        }

        pub fn deinit(self: Self) void {
            c.JS_FreeContext(self.ptr);
        }

        pub fn getRuntime(self: Self) Runtime(T) {
            return c.JS_GetRuntime(self.ptr);
        }

        pub fn newFunction(self: Self, func: *const c.JSCFunction, name: [*]const u8, length: c_int) c.JSValue {
            // TODO: handle unreachable
            return c.JS_NewCFunction(self.ptr, func, name, length) orelse unreachable;
        }

        pub fn getGlobalObject(self: Self) c.JSValue {
            // TODO: handle unreachable
            return c.JS_GetGlobalObject(self.ptr) orelse unreachable;
        }

        // TODO: fix return type
        pub fn setPropString(self: Self, this: c.JSValueConst, prop: [*]const u8, value: c.JSValue) ?*anyopaque {
            return c.JS_SetPropertyStr(self.ptr, this, prop, value);
        }

        pub fn getPropString(self: Self, this: c.JSValueConst, prop: [*]const u8) ?c.JSValue {
            return c.JS_GetPropertyStr(self.ptr, this, prop);
        }

        pub fn freeValue(self: Self, value: ?c.JSValue) void {
            return c.JS_FreeValue(self.ptr, value);
        }

        pub fn eval(self: Self, input: [*:0]u8, input_len: usize, filename: [*:0]u8, eval_flag: Enums.EvalFlags) ?c.JSValue {
            return c.JS_Eval(self.ptr, input, input_len, filename, @as(c_int, eval_flag));
        }

        pub fn getException(self: Self) ?c.JSValue {
            return c.JS_GetException(self.ptr);
        }

        pub fn toString(self: Self, val: c.JSValueConst) [*]const u8 {
            return c.JS_ToCString(self.ptr, val);
        }
    };
}
