const std = @import("std");
const JSAllocator = @import("js_allocator.zig");
const debug = @import("debug.zig");
const js_std = @import("js_std.zig");
const c = @cImport({
    @cInclude("quickjs/quickjs.h");
});
const Runtime = @import("qjs/Runtime.zig");

fn loadModule(ctx: ?*c.JSContext, filename: ?[*]const u8, extra: ?*anyopaque) callconv(.C) ?*c.JSModuleDef {
    _ = extra;

    std.debug.print("filename: {s}\n", .{@ptrCast([*:0]const u8, filename.?)});

    const allocator = @ptrCast(
        *JSAllocator,
        @alignCast(@alignOf(JSAllocator), c.JS_GetRuntimeOpaque(c.JS_GetRuntime(ctx))),
    );

    const module_code = std.fs.cwd().readFileAllocOptions(
        allocator.allocator,
        std.mem.span(@ptrCast([*:0]const u8, filename.?)),
        std.math.maxInt(usize),
        null,
        1,
        0,
    ) catch unreachable;

    const result = c.JS_Eval(
        ctx,
        module_code.ptr,
        module_code.len,
        filename,
        c.JS_EVAL_TYPE_MODULE | c.JS_EVAL_FLAG_COMPILE_ONLY,
    );

    return @ptrCast(?*c.JSModuleDef, result.u.ptr);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){};
    gpa.requested_memory_limit = 24 * 1024 * 1024;
    // defer std.debug.assert(!gpa.deinit());
    const allocator = gpa.allocator();
    defer std.debug.print("total requested bytes: {}\n", .{gpa.total_requested_bytes});

    const runtime = Runtime.init(allocator) orelse return error.NoRuntime;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var js_allocator = JSAllocator.init(allocator);
    defer js_allocator.deinit();

    c.JS_SetRuntimeOpaque(runtime, &js_allocator);
    defer c.JS_FreeRuntime(runtime);

    var ctx = c.JS_NewContext(runtime) orelse return error.NoContext;
    defer c.JS_FreeContext(ctx);

    const print = c.JS_NewCFunction(ctx, @ptrCast(*const c.JSCFunction, &js_std.print), "print", 1);
    defer c.JS_FreeValue(ctx, print);

    const global = c.JS_GetGlobalObject(ctx);
    _ = c.JS_SetPropertyStr(ctx, global, "print", print);

    const readFileSync = c.JS_NewCFunction(ctx, @ptrCast(*const c.JSCFunction, &js_std.readFileSync), "readFileSync", 1);
    defer c.JS_FreeValue(ctx, readFileSync);
    _ = c.JS_SetPropertyStr(ctx, global, "readFileSync", readFileSync);

    c.JS_SetModuleLoaderFunc(runtime, null, &loadModule, null);

    for (args[1..]) |arg| {
        const js_code = try std.fs.cwd().readFileAllocOptions(allocator, arg, std.math.maxInt(usize), null, 1, 0);
        defer allocator.free(js_code);
        const result = c.JS_Eval(ctx, js_code.ptr, js_code.len, arg, c.JS_EVAL_TYPE_MODULE);
        if (result.tag == c.JS_TAG_EXCEPTION) {
            const exc = c.JS_GetException(ctx);
            std.debug.print("\x1b[33mUnhandled exception from {s}\x1b[0m:\n\x1b[31m{s}\x1b[0m\n{s}\n", .{
                arg,
                c.JS_ToCString(ctx, c.JS_GetPropertyStr(ctx, exc, "message")),
                c.JS_ToCString(ctx, c.JS_GetPropertyStr(ctx, exc, "stack")),
            });
        }
        defer c.JS_FreeValue(ctx, result);
    }
}
