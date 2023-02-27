const std = @import("std");
const c = @cImport({
    @cInclude("quickjs/quickjs.h");
});

pub fn printJSValue(ctx: *c.JSContext, v: c.JSValue) !void {
    switch (v.tag) {
        c.JS_TAG_UNDEFINED => {
            std.debug.print("\x1b[30mundefined\x1b[0m", .{});
        },
        c.JS_TAG_EXCEPTION => {
            std.debug.print("It's an exception\n", .{});
            const exc = c.JS_GetException(ctx);
            defer c.JS_FreeValue(ctx, exc);
            try printJSValue(ctx, exc);
        },
        c.JS_TAG_OBJECT => {
            std.debug.print("It's an object\n", .{});
            const cstr = c.JS_ToCString(ctx, v);
            defer c.JS_FreeCString(ctx, cstr);
            std.debug.print("{s}", .{cstr});
        },
        c.JS_TAG_STRING => {
            const str = c.JS_ToCString(ctx, v);
            defer c.JS_FreeCString(ctx, str);
            std.debug.print("\x1b[32m\"{s}\"\x1b[0m", .{str});
        },
        c.JS_TAG_INT => {
            std.debug.print("\x1b[33m{}\x1b[0m", .{v.u.int32});
        },
        c.JS_TAG_FLOAT64 => {
            std.debug.print("\x1b[33m{d}\x1b[0m", .{v.u.float64});
        },
        else => {
            std.debug.print("\x1b[31mInvalid tag: {}\x1b[0m\n", .{v.tag});
            return error.InvalidTag;
        },
    }
}
