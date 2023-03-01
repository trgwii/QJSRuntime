const std = @import("std");
const Context = @import("qjs/Context.zig").Context;

pub fn write(_: Context(void, std.mem.Allocator), fd: i32, bytes: []const u8) i32 {
    return @intCast(i32, std.os.write(fd, bytes) catch return -1);
}
