const std = @import("std");

// TODO: (long-term) get rid of c import in main
const c = @cImport({
    @cInclude("quickjs/quickjs.h");
});
const Runtime = @import("qjs/Runtime.zig").Runtime;
const Context = @import("qjs/Context.zig").Context;
const Value = @import("qjs/Value.zig").Value;
const jsTagToString = @import("qjs/Context.zig").jsTagToString;

fn load(_ctx: ?*c.JSContext, path: ?[*:0]const u8, state: ?*anyopaque) callconv(.C) ?*c.JSModuleDef {
    const ctx = Context(void, void){ .ptr = _ctx.? };
    const allocator = @ptrCast(*const std.mem.Allocator, @alignCast(@alignOf(std.mem.Allocator), state.?)).*;
    if (std.mem.eql(u8, "std", std.mem.span(path.?))) {
        return @ptrCast(?*c.JSModuleDef, ctx.eval(
            @embedFile("js_std"),
            "std",
            c.JS_EVAL_TYPE_MODULE | c.JS_EVAL_FLAG_COMPILE_ONLY,
        ).val.u.ptr);
    }
    const code = std.fs.cwd().readFileAllocOptions(
        allocator,
        std.mem.span(path.?),
        std.math.maxInt(usize),
        null,
        1,
        0,
    ) catch {
        std.debug.print("\x1b[91mFailed to load module '{s}'\n", .{path.?});
        std.os.exit(0); // TEMP solution
    };
    defer allocator.free(code);
    return @ptrCast(?*c.JSModuleDef, ctx.eval(
        code,
        path.?,
        c.JS_EVAL_TYPE_MODULE | c.JS_EVAL_FLAG_COMPILE_ONLY,
    ).val.u.ptr);
}

fn printException(ctx: Context(void, void), exc: Value(void, void)) !void {
    const name = exc.prop(ctx, "name");
    defer name.free(ctx);

    const msg = exc.prop(ctx, "message");
    defer msg.free(ctx);

    const stack = exc.prop(ctx, "stack");
    defer stack.free(ctx);

    if (msg.val.tag != c.JS_TAG_STRING) {
        const exc_str = try exc.toString(ctx);
        defer exc.freeString(ctx, exc_str);

        std.debug.print("\x1b[91mUnhandled exception ({s}): {s}\x1b[0m\n", .{ jsTagToString(exc.val.tag), exc_str });
        return;
    }
    const name_str = try name.toString(ctx);
    defer name.freeString(ctx, name_str);

    const message_str = try msg.toString(ctx);
    defer msg.freeString(ctx, message_str);

    const stack_str = try stack.toString(ctx);
    defer stack.freeString(ctx, stack_str);

    std.debug.print("\x1b[91m{s}: {s}\n{s}\x1b[0m\n", .{ name_str, message_str, stack_str });
}

// TODO: Start asynchronous processing, good first candidates:
// * setTimeout / clearTimeout
// * readFileAsync
// * Async network sockets

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
    }){
        .requested_memory_limit = 100 * 1024 * 1024,
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

    ctx.eval(
        \\import { log } from 'std';
        \\globalThis.console = { log };
    , "prelude", c.JS_EVAL_TYPE_MODULE).free(ctx);

    if (args.len == 1) {
        var line = std.ArrayList(u8).init(allocator);
        defer line.deinit();
        const glob = ctx.globalThis();
        defer glob.free(ctx);
        const console = glob.prop(ctx, "console");
        defer console.free(ctx);
        const log = console.prop(ctx, "log");
        defer log.free(ctx);
        while (true) : (line.clearRetainingCapacity()) {
            if (c.JS_IsJobPending(rt.ptr) > 0) {
                var ptr: ?*c.JSContext = null;
                _ = c.JS_ExecutePendingJob(rt.ptr, &ptr);
            }
            std.io.getStdIn().reader().readUntilDelimiterArrayList(&line, '\n', 1024 * 1024) catch break;
            try line.append(0);
            var res = ctx.eval(line.items[0 .. line.items.len - 1 :0], "<repl>", c.JS_EVAL_TYPE_GLOBAL);
            defer res.free(ctx);

            if (res.val.tag == c.JS_TAG_EXCEPTION) {
                const exc = ctx.getException();
                defer exc.free(ctx);
                try printException(ctx, exc);
            } else {
                // TODO: Call inspect here manually so string literal results of expressions get printed as "foo" rather than foo
                const val = c.JS_Call(ctx.ptr, log.val, .{ .tag = c.JS_TAG_UNDEFINED, .u = .{ .ptr = null } }, 1, &res.val);
                defer c.JS_FreeValue(ctx.ptr, val);
            }
        }
    } else for (args[1..]) |arg| {
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
            try printException(ctx, exc);
        }

        while (c.JS_IsJobPending(rt.ptr) > 0) {
            var ptr: ?*c.JSContext = null;
            _ = c.JS_ExecutePendingJob(rt.ptr, &ptr);
        }
    }
}
