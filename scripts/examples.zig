const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!gpa.deinit());
    const allocator = gpa.allocator();

    const files = .{
        "examples/playground/foo.js",
        "examples/playground/test.js",
        "examples/playground/exit.js",
        "examples/core/test.js",
        "examples/logging.js",
        "examples/std-loading.js",
        "examples/global-console.js",
        "examples/failing-import.js",
        "examples/core/readFileSync.js",
        "examples/core/timer-ids.js",
        "examples/core/writeSync.js",
        "examples/core/file_ops.js",
        "examples/core/net_ops.js",
    };

    inline for (files) |file| {
        var line = [_]u8{'='} ** 80;
        _ = try std.fmt.bufPrint(line[20..], " Running {s} ", .{file});
        std.debug.print("{s}\n", .{line});
        const result = try std.ChildProcess.exec(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "zig", "build", "run", "--", file },
        });
        defer allocator.free(result.stderr);
        defer allocator.free(result.stdout);
        std.debug.print("{s}", .{result.stdout});
        std.debug.print("{s}", .{result.stderr});
    }
}
