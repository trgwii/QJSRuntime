const std = @import("std");
const c = @import("qjs/c.zig");
const Context = @import("qjs/Context.zig").Context;
const jsTagToString = @import("qjs/Context.zig").jsTagToString;
const Value = @import("qjs/Value.zig").Value;
const ContextState = @import("main.zig").ContextState;

const Ctx = Context(void, ContextState);
const Val = Value(void, ContextState);

fn uint8ArrayToSlice(ctx: Ctx, uint8Array: Val) ?[]u8 {
    var size: usize = 0;
    const buffer = uint8Array.getProp("buffer");
    defer ctx.free(buffer);
    const _offset = uint8Array.getProp("byteOffset");
    defer ctx.free(_offset);
    const _length = uint8Array.getProp("byteLength");
    defer ctx.free(_length);

    const offset = std.math.cast(usize, _offset.val.u.int32) orelse return null;
    const length = std.math.cast(usize, _length.val.u.int32) orelse return null;

    const bytes = @ptrCast(?[*]u8, c.JS_GetArrayBuffer(ctx.ptr, &size, buffer.val)) orelse return null;
    if (offset + length > size) return null;

    return bytes[offset .. offset + length];
}

pub const stdin: i32 = std.os.STDIN_FILENO;
pub const stdout: i32 = std.os.STDOUT_FILENO;
pub const stderr: i32 = std.os.STDERR_FILENO;

pub fn openSync(_: Ctx, path: []const u8) i32 {
    const file = std.fs.cwd().openFile(path, .{ .mode = .read_write }) catch return -1;
    return file.handle;
}

pub fn connectSync(ctx: Ctx, addrport: []const u8) i32 {
    const split = std.mem.indexOf(u8, addrport, ":") orelse return -1;
    const addr = addrport[0..split];
    const port = std.fmt.parseUnsigned(u16, addrport[split + 1 ..], 10) catch return -1;
    const state = ctx.getState().?;
    const stream = std.net.tcpConnectToHost(state.allocator, addr, port) catch return -1;
    return stream.handle;
}

pub fn closeSync(_: Ctx, fd: i32) void {
    const file = std.fs.File{ .handle = fd };
    file.close();
}

pub fn readSync(ctx: Ctx, fd: i32, uint8Array: Val) i32 {
    const slice = uint8ArrayToSlice(ctx, uint8Array) orelse return -1;
    return std.math.cast(i32, std.os.read(fd, slice) catch return -1) orelse return -1;
}

pub fn writeSync(ctx: Ctx, fd: i32, uint8Array: Val) i32 {
    const slice = uint8ArrayToSlice(ctx, uint8Array) orelse return -1;
    return std.math.cast(i32, std.os.write(fd, slice) catch return -1) orelse return -1;
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
pub fn setTimeout(ctx: Ctx, func: Val, ms: i32) i32 {
    const state = ctx.getState().?;
    const id: i32 = state.next_timer_id;

    const gop = state.timers.getOrPut(state.allocator, id) catch return -1;
    std.debug.assert(!gop.found_existing);
    gop.value_ptr.* = .{
        .timestamp = std.time.milliTimestamp() + ms,
        .js_func = func.dupe(),
    };
    state.next_timer_id +%= 1;
    return id;
}

pub fn clearTimeout(ctx: Ctx, id: i32) void {
    const state = ctx.getState().?;
    if (state.timers.fetchSwapRemove(id)) |kv| {
        ctx.free(kv.value.js_func);
    }
}
