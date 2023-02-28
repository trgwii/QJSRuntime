const std = @import("std");
const JSAllocator = @import("js_allocator.zig");
const debug = @import("debug.zig");
const js_std = @import("js_std.zig");
const c = @import("qjs/c.zig");
const Runtime = @import("qjs/Runtime.zig").Runtime;
const Context = @import("qjs/Context.zig").Context;
const Enums = @import("qjs/enums.zig");
const types = @import("qjs/types.zig");

fn loadModule(comptime T: type) type {
    return struct {
        fn load(_ctx: *c.JSContext, filename: ?[*]const u8, extra: ?*anyopaque) callconv(.C) ?*types.JSModuleDef {
            _ = extra;
            const ctx: Context(T) = .{ .ptr = _ctx };

            std.debug.print("filename: {s}\n", .{@ptrCast([*:0]const u8, filename.?)});

            const allocator = @ptrCast(
                *JSAllocator,
                @alignCast(@alignOf(JSAllocator), ctx.getRuntime().getState()),
            );

            const module_code = std.fs.cwd().readFileAllocOptions(
                allocator.allocator,
                std.mem.span(@ptrCast([*:0]const u8, filename.?)),
                std.math.maxInt(usize),
                null,
                1,
                0,
            ) catch unreachable;

            const result = ctx.eval(
                module_code.ptr,
                module_code.len,
                filename,
                Enums.EvalFlags.JS_EVAL_TYPE_MODULE | Enums.EvalFlags.JS_EVAL_FLAG_COMPILE_ONLY,
            );

            return @ptrCast(?*types.JSModuleDef, result.u.ptr);
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){};
    gpa.requested_memory_limit = 24 * 1024 * 1024;
    // defer std.debug.assert(!gpa.deinit());
    const allocator = gpa.allocator();
    defer std.debug.print("total requested bytes: {}\n", .{gpa.total_requested_bytes});

    const runtime = Runtime(*JSAllocator).init(allocator) orelse return error.NoRuntime;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var js_allocator = JSAllocator.init(allocator);
    defer js_allocator.deinit();

    runtime.setState(&js_allocator);
    defer runtime.deinit();

    var ctx = runtime.createContext() orelse return error.NoContext;
    defer ctx.deinit();

    const print = ctx.newFunction(@ptrCast(*const types.JSCFunction, &js_std.print), "print", 1);
    defer ctx.freeValue(print);

    const global = ctx.getGlobalObject();
    _ = ctx.setPropString(global, "print", print);

    const readFileSync = ctx.newFunction(@ptrCast(*const types.JSCFunction, &js_std.readFileSync), "readFileSync", 1);
    defer ctx.freeValue(readFileSync);
    _ = ctx.setPropString(global, "readFileSync", readFileSync);

    runtime.setModuleLoader(null, &loadModule(*JSAllocator).load, null);

    for (args[1..]) |arg| {
        const js_code = try std.fs.cwd().readFileAllocOptions(allocator, arg, std.math.maxInt(usize), null, 1, 0);
        defer allocator.free(js_code);
        const result = ctx.eval(js_code.ptr, js_code.len, arg, Enums.EvalFlags.JS_EVAL_TYPE_MODULE);
        // if (result.tag == Enums.JSTags.JS_TAG_EXCEPTION) {
        //     const exc = ctx.getException();
        //     std.debug.print("\x1b[33mUnhandled exception from {s}\x1b[0m:\n\x1b[31m{s}\x1b[0m\n{s}\n", .{
        //         arg,
        //         ctx.toString(ctx.getPropString(ctx, exc, "message")),
        //         ctx.toString(ctx.getPropString(ctx, exc, "stack")),
        //     });
        // }
        defer ctx.freeValue(result);
    }
}
