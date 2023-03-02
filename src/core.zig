const std = @import("std");
const Context = @import("qjs/Context.zig").Context;

// TODO: support more syscalls

pub fn write(_: Context(void, std.mem.Allocator), fd: i32, bytes: []const u8) i32 {
    return @intCast(i32, std.os.write(fd, bytes) catch return -1);
}

pub fn exit(_: Context(void, std.mem.Allocator), code: i32) noreturn {
    std.os.exit(@intCast(u8, code));
}

// TODO: Support non-function declarations, replace these with constants
pub fn stdin(_: Context(void, std.mem.Allocator)) i32 {
    return std.os.STDIN_FILENO;
}
pub fn stdout(_: Context(void, std.mem.Allocator)) i32 {
    return std.os.STDOUT_FILENO;
}
pub fn stderr(_: Context(void, std.mem.Allocator)) i32 {
    return std.os.STDERR_FILENO;
}
