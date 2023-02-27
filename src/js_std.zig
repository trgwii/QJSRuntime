const std = @import("std");
const debug = @import("debug.zig");
const JSAllocator = @import("js_allocator.zig");
const c = @cImport({
    @cInclude("quickjs/quickjs.h");
});

pub fn print(ctx: *c.JSContext, this: c.JSValue, argc: c_int, argv: [*]c.JSValue) callconv(.C) c.JSValue {
    _ = this;
    for (0..@intCast(usize, argc)) |i| {
        if (i > 0) std.debug.print(" ", .{});
        debug.printJSValue(ctx, argv[i]) catch unreachable;
    }
    std.debug.print("\n", .{});
    return .{ .tag = c.JS_TAG_UNDEFINED, .u = .{ .ptr = null } };
}

pub fn readFileSync(ctx: *c.JSContext, this: c.JSValue, argc: c_int, argv: [*]c.JSValue) callconv(.C) c.JSValue {
    _ = this;
    _ = argc;
    const allocator = @ptrCast(*JSAllocator, @alignCast(@alignOf(JSAllocator), c.JS_GetRuntimeOpaque(c.JS_GetRuntime(ctx))));
    const bytes = std.fs.cwd().readFileAllocOptions(allocator.allocator, std.mem.span(@ptrCast([*:0]const u8, c.JS_ToCString(ctx, argv[0]))), std.math.maxInt(usize), null, 1, 0) catch unreachable;
    defer allocator.allocator.free(bytes);
    return c.JS_NewStringLen(ctx, bytes.ptr, bytes.len);
}
