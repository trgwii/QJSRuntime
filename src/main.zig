const std = @import("std");
const c = @cImport({
    @cInclude("quickjs/quickjs.h");
});
const Runtime = @import("qjs/Runtime.zig").Runtime;
const Context = @import("qjs/Context.zig").Context;

fn js_print(_: Context(void, std.mem.Allocator), str: []const u8) void {
    std.debug.print("{s}\n", .{str});
}

fn load(_ctx: ?*c.JSContext, path: ?[*:0]const u8, state: ?*anyopaque) callconv(.C) ?*c.JSModuleDef {
    const ctx = Context(void, void){ .ptr = _ctx.? };
    const allocator = @ptrCast(*const std.mem.Allocator, @alignCast(@alignOf(std.mem.Allocator), state.?)).*;
    const code = std.fs.cwd().readFileAllocOptions(
        allocator,
        std.mem.span(path.?),
        std.math.maxInt(usize),
        null,
        1,
        0,
    ) catch return null;
    defer allocator.free(code);
    return @ptrCast(?*c.JSModuleDef, ctx.eval(
        code,
        path.?,
        c.JS_EVAL_TYPE_MODULE | c.JS_EVAL_FLAG_COMPILE_ONLY,
    ).val.u.ptr);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){
        .requested_memory_limit = 128 * 1024,
    };
    defer std.debug.assert(!gpa.deinit());
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var rt = try Runtime(void).init(&allocator);
    defer rt.deinit();

    rt.setModuleLoader(std.mem.Allocator, &load, @constCast(&allocator));

    const ctx = try rt.createContext(void);
    defer ctx.deinit();

    const print = ctx.createFunction("print", js_print);
    defer print.free(ctx);

    const global = ctx.globalThis();
    defer global.free(ctx);
    _ = global.setProp(ctx, "print", print);

    for (args[1..]) |arg| {
        const code = try std.fs.cwd().readFileAllocOptions(
            allocator,
            arg,
            std.math.maxInt(usize),
            null,
            1,
            0,
        );
        defer allocator.free(code);
        const result = ctx.eval(code, arg, c.JS_EVAL_TYPE_MODULE);
        defer result.free(ctx);

        if (result.val.tag == 6) {
            const exc = ctx.getException();
            defer exc.free(ctx);

            const msg = exc.prop(ctx, "message");
            defer msg.free(ctx);

            const str = try msg.toString(ctx);
            defer msg.freeString(ctx, str);

            std.debug.print("{s}\n", .{str});
        }
    }
}
