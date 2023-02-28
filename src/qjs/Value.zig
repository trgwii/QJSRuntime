const Context = @import("Context.zig").Context;

const c = @cImport({
    @cInclude("quickjs/quickjs.h");
});

pub fn Value(comptime RtState: type, comptime CtxState: type) type {
    return struct {
        val: c.JSValue,

        const Self = @This();
        const Ctx = Context(RtState, CtxState);

        pub fn prop(self: Self, ctx: Ctx, name: [*:0]const u8) Value(RtState, CtxState) {
            return .{ .val = c.JS_GetPropertyStr(ctx.ptr, self.val, name) };
        }

        // TODO: Return type
        pub fn setProp(self: Self, ctx: Ctx, name: [*:0]const u8, val: Self) i32 {
            return c.JS_SetPropertyStr(ctx.ptr, self.val, name, val.val);
        }

        pub fn toString(self: Self, ctx: Ctx) ![*:0]const u8 {
            return c.JS_ToCString(ctx.ptr, self.val) orelse return error.OutOfMemory;
        }

        pub fn freeString(self: Self, ctx: Ctx, str: [*:0]const u8) void {
            _ = self;
            c.JS_FreeCString(ctx.ptr, str);
        }

        pub fn free(self: Self, ctx: Ctx) void {
            c.JS_FreeValue(ctx.ptr, self.val);
        }
    };
}
