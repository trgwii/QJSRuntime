const std = @import("std");

// TODO: (long-term) get rid of c import in main
const c = @import("qjs/c.zig");
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
        std.debug.print("\x1b[91mFailed to load module '{s}'\x1b[0m\n", .{path.?});
        std.os.exit(0); // TEMP solution
    };
    defer allocator.free(code);
    return @ptrCast(?*c.JSModuleDef, ctx.eval(
        code,
        path.?,
        c.JS_EVAL_TYPE_MODULE | c.JS_EVAL_FLAG_COMPILE_ONLY,
    ).val.u.ptr);
}

const Val = Value(void, ContextState);

fn printException(ctx: Context(void, ContextState), exc: Val) !void {
    const name = exc.getProp("name");
    defer ctx.free(name);

    const msg = exc.getProp("message");
    defer ctx.free(msg);

    const stack = exc.getProp("stack");
    defer ctx.free(stack);

    if (msg.val.tag != c.JS_TAG_STRING) {
        const exc_str = try exc.toString();
        defer ctx.freeString(exc_str);

        std.debug.print("\x1b[91mUnhandled exception ({s}): {s}\x1b[0m\n", .{ jsTagToString(exc.val.tag), exc_str });
        return;
    }
    const name_str = try name.toString();
    defer ctx.freeString(name_str);

    const message_str = try msg.toString();
    defer ctx.freeString(message_str);

    const stack_str = try stack.toString();
    defer ctx.freeString(stack_str);

    std.debug.print("\x1b[91m{s}: {s}\n{s}\x1b[0m\n", .{ name_str, message_str, stack_str });
}

// TODO: Start asynchronous processing, good first candidates:
// * clearTimeout
// * readFileAsync
// * Async network sockets

pub const Timer = struct {
    timestamp: i64,
    js_func: Val,
    done: bool = false,
};

fn allTimersDone(timers: []const Timer) bool {
    for (timers) |timer| if (!timer.done) return false;
    return true;
}

pub const ContextState = struct {
    allocator: std.mem.Allocator,
    timers: std.ArrayListUnmanaged(Timer),
};

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

    const ctx = try rt.createContext(ContextState);
    defer ctx.deinit();

    var state = ContextState{
        .allocator = allocator,
        .timers = std.ArrayListUnmanaged(Timer){},
    };
    defer state.timers.deinit(allocator);

    ctx.setState(&state);

    ctx.free(ctx.eval(
        \\import { log } from 'std';
        \\globalThis.console = { log };
    , "prelude", c.JS_EVAL_TYPE_MODULE));

    if (args.len == 1) {
        var line = std.ArrayList(u8).init(allocator);
        defer line.deinit();
        const glob = ctx.globalThis();
        defer ctx.free(glob);
        const console = glob.getProp("console");
        defer ctx.free(console);
        const log = console.getProp("log");
        defer ctx.free(log);
        while (true) : (line.clearRetainingCapacity()) {
            if (c.JS_IsJobPending(rt.ptr) > 0) {
                var ptr: ?*c.JSContext = null;
                _ = c.JS_ExecutePendingJob(rt.ptr, &ptr);
            }
            std.io.getStdIn().reader().readUntilDelimiterArrayList(&line, '\n', 1024 * 1024) catch break;
            try line.append(0);
            var res = ctx.eval(line.items[0 .. line.items.len - 1 :0], "<repl>", c.JS_EVAL_TYPE_GLOBAL);
            defer ctx.free(res);

            if (res.val.tag == c.JS_TAG_EXCEPTION) {
                const exc = ctx.getException();
                defer ctx.free(exc);
                try printException(ctx, exc);
            } else {
                // TODO: Call inspect here manually so string literal results of expressions get printed as "foo" rather than foo
                // (That is, have to get a reference to inspect from `import { inspect } from 'std';` somehow
                //     then call it with res.val, and then call console.log with the result of that)
                const val = log.call(ctx.createValue(c.JS_TAG_UNDEFINED, null), 1, &[_]Val{res});
                defer ctx.free(val);
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
        defer ctx.free(result);

        if (result.val.tag == 6) {
            const exc = ctx.getException();
            defer ctx.free(exc);
            try printException(ctx, exc);
        }

        while (c.JS_IsJobPending(rt.ptr) > 0 or !allTimersDone(state.timers.items)) {
            var ptr: ?*c.JSContext = null;
            _ = c.JS_ExecutePendingJob(rt.ptr, &ptr);
            const now = std.time.milliTimestamp();
            for (state.timers.items) |*timer| {
                if (!timer.done and timer.timestamp <= now) {
                    // TODO: print exception if call fails
                    const res = timer.js_func.call(ctx.createValue(c.JS_TAG_UNDEFINED, null), 0, null);
                    ctx.free(timer.js_func);
                    ctx.free(res);
                    timer.done = true;
                }
            }
        }
    }
}
