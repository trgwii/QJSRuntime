const c = @import("c.zig");
const Context = @import("Context.zig").Context;
const ContextState = @import("../main.zig").ContextState;

pub fn Value(comptime RtState: type, comptime CtxState: type) type {
    return struct {
        val: c.JSValue,
        ctx: Context(RtState, CtxState),

        const Self = @This();
        const Ctx = Context(RtState, CtxState);
        const Val = Value(RtState, CtxState);

        pub fn getProp(self: Self, name: [*:0]const u8) Val {
            return .{ .val = c.JS_GetPropertyStr(self.ctx.ptr, self.val, name), .ctx = self.ctx };
        }

        // TODO: Wrap return type as an error union or something
        pub fn setProp(self: Self, name: [*:0]const u8, val: Self) i32 {
            return c.JS_SetPropertyStr(self.ctx.ptr, self.val, name, val.val);
        }

        pub fn toString(self: Self) ![*:0]const u8 {
            return c.JS_ToCString(self.ctx.ptr, self.val) orelse return error.OutOfMemory;
        }

        pub fn dupe(self: Self) Val {
            return .{ .val = c.JS_DupValue(self.ctx.ptr, self.val), .ctx = self.ctx };
        }

        pub fn call(self: Self, this_obj: Self, argc: c_int, args: ?[]Self) Val {
            // map []Value to []JSValue
            const argv: []c.JSValue = if (args) |as| blk: {
                const state = @ptrCast(*ContextState, @alignCast(@alignOf(ContextState), self.ctx.getState().?));
                const argv = state.allocator.alloc(c.JSValue, as.len) catch unreachable;
                for (as, 0..) |arg, i|
                    argv[i] = arg.val;
                defer state.allocator.free(argv);
                break :blk argv;
            } else &[_]c.JSValue{};

            return .{ .val = c.JS_Call(self.ctx.ptr, self.val, this_obj.val, argc, argv.ptr), .ctx = self.ctx };
        }
    };
}
