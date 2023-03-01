const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = std.zig.CrossTarget.parse(.{
            .arch_os_abi = "x86_64-linux",
        }) catch unreachable,
    });

    const optimize = b.standardOptimizeOption(.{});

    const quickjs = b.addStaticLibrary(.{
        .name = "quickjs",
        .target = target,
        .optimize = .ReleaseFast,
        .root_source_file = .{ .path = "deps/quickjs/quickjs.c" },
    });
    quickjs.linkLibC();
    quickjs.defineCMacro(
        "CONFIG_VERSION",
        "\"" ++ comptime std.mem.trim(
            u8,
            @embedFile("deps/quickjs/VERSION"),
            "\n",
        ) ++ "\"",
    );
    quickjs.defineCMacro("CONFIG_BIGNUM", null);
    quickjs.addCSourceFiles(&[_][]const u8{
        "deps/quickjs/libunicode.c",
        "deps/quickjs/libregexp.c",
        "deps/quickjs/libbf.c",
        "deps/quickjs/cutils.c",
    }, &[_][]const u8{});

    const exe = b.addExecutable(.{
        .name = "QJSRuntime",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "src/main.zig" },
    });
    exe.linkLibrary(quickjs);
    exe.addIncludePath("deps");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
