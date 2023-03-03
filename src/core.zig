const std = @import("std");
const Context = @import("qjs/Context.zig").Context;
const Value = @import("qjs/Value.zig").Value;
const ContextState = @import("main.zig").ContextState;

const Ctx = Context(void, ContextState);

// TODO: support more syscalls here

pub fn write(_: Ctx, fd: i32, bytes: []const u8) i32 {
    return @intCast(i32, std.os.write(fd, bytes) catch return -1);
}

pub fn exit(_: Ctx, code: i32) noreturn {
    std.os.exit(@intCast(u8, code));
}

pub fn readFileSync(ctx: Ctx, path: []const u8) []const u8 {
    const ctx_state = ctx.getState() orelse return "";
    const file_data = std.fs.cwd().readFileAlloc(ctx_state.allocator, path, std.math.maxInt(usize)) catch return "";
    return file_data;
}

// TODO: store parameters, support calling func with more parameters
pub fn setTimeout(ctx: Ctx, func: Value(void, ContextState), ms: i32) i32 {
    const state = ctx.getState().?;
    state.timers.append(state.allocator, .{
        .timestamp = std.time.milliTimestamp() + ms,
        .js_func = func.dupe(),
    }) catch return -1;
    const id = @intCast(i32, state.timers.items.len - 1);
    return id;
}

// TODO: Support non-function declarations, replace these with constants
// (Requires editing qjs/Context.zig:133 (comptime function init))
pub fn stdin(_: Ctx) i32 {
    return std.os.STDIN_FILENO;
}
pub fn stdout(_: Ctx) i32 {
    return std.os.STDOUT_FILENO;
}
pub fn stderr(_: Ctx) i32 {
    return std.os.STDERR_FILENO;
}
