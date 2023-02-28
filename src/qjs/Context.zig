const std = @import("std");
const c = @cImport({
    @cInclude("quickjs/quickjs.h");
});
const Value = @import("Value.zig").Value;
const Runtime = @import("Runtime.zig").Runtime;

pub fn Context(comptime RtState: type, comptime CtxState: type) type {
    return struct {
        ptr: *c.JSContext,

        const Self = @This();

        pub fn init(rt: *c.JSRuntime) !Self {
            return .{ .ptr = c.JS_NewContext(rt) orelse return error.OutOfMemory };
        }

        pub fn deinit(self: Self) void {
            c.JS_FreeContext(self.ptr);
        }

        pub fn getState(self: Self) ?*CtxState {
            return c.JS_GetContextOpaque(self.ptr);
        }

        pub fn setState(self: Self, state: *CtxState) void {
            c.JS_SetContextOpaque(self.ptr, state);
        }

        pub fn runtime(self: Self) Runtime(RtState) {
            return .{ .ptr = c.JS_GetRuntime(self.ptr) };
        }

        // TODO: Support all types
        pub fn createFunction(self: Self, name: [:0]const u8, func: anytype) Value(RtState, CtxState) {
            const info = @typeInfo(@TypeOf(func)).Fn;
            return .{
                .val = c.JS_NewCFunction(self.ptr, struct {
                    fn _(_ctx: ?*c.JSContext, this: c.JSValue, argc: i32, argv: ?[*]c.JSValue) callconv(.C) c.JSValue {
                        const ctx = Context(RtState, CtxState){ .ptr = _ctx.? };
                        _ = this;
                        if (argc != info.params.len - 1) {
                            const err = ctx.createError();
                            const msg = ctx.createString("Invalid number of arguments");
                            _ = err.setProp(ctx, "message", msg);
                            const exc = c.JS_Throw(ctx.ptr, err.val);
                            return exc;
                        }
                        comptime var fields: []const std.builtin.Type.StructField = &[_]std.builtin.Type.StructField{.{
                            .name = "0",
                            .type = info.params[0].type.?,
                            .default_value = null,
                            .is_comptime = false,
                            .alignment = @alignOf(info.params[0].type.?),
                        }};
                        inline for (info.params[1..], 0..) |param, i| {
                            switch (param.type.?) {
                                []const u8 => {
                                    fields = fields ++ &[_]std.builtin.Type.StructField{.{
                                        .name = comptime std.fmt.comptimePrint("{}", .{i + 1}),
                                        .type = param.type.?,
                                        .default_value = null,
                                        .is_comptime = false,
                                        .alignment = @alignOf(param.type.?),
                                    }};
                                },
                                else => @compileError("Unsupported type: " ++ @typeName(param.type)),
                            }
                        }
                        var params: @Type(.{ .Struct = .{
                            .layout = .Auto,
                            .fields = fields,
                            .decls = &[_]std.builtin.Type.Declaration{},
                            .is_tuple = true,
                        } }) = undefined;
                        inline for (0..params.len - 1) |i| {
                            switch (@TypeOf(params[i + 1])) {
                                []const u8 => {
                                    params[i + 1] = std.mem.span(@ptrCast([*:0]const u8, c.JS_ToCString(ctx.ptr, argv.?[i])));
                                },
                                else => @compileError("Unsupported type: " ++ @typeName(@TypeOf(params[i + 1]))),
                            }
                        }
                        // TODO: Return value
                        @call(.auto, func, params);
                        inline for (0..params.len - 1) |i| {
                            switch (@TypeOf(params[i + 1])) {
                                []const u8 => {
                                    c.JS_FreeCString(ctx.ptr, params[i + 1].ptr);
                                },
                                else => @compileError("Unsupported type: " ++ @typeName(@TypeOf(params[i + 1]))),
                            }
                        }
                        return .{ .tag = c.JS_TAG_UNDEFINED, .u = .{ .ptr = null } };
                    }
                }._, name.ptr, info.params.len),
            };
        }

        pub fn globalThis(self: Self) Value(RtState, CtxState) {
            return .{ .val = c.JS_GetGlobalObject(self.ptr) };
        }

        pub fn createError(self: Self) Value(RtState, CtxState) {
            return .{ .val = c.JS_NewError(self.ptr) };
        }

        pub fn createString(self: Self, str: []const u8) Value(RtState, CtxState) {
            return .{ .val = c.JS_NewStringLen(self.ptr, str.ptr, str.len) };
        }

        pub fn eval(self: Self, input: [:0]const u8, filename: [*:0]const u8, eval_flags: i32) Value(RtState, CtxState) {
            return .{ .val = c.JS_Eval(self.ptr, input.ptr, input.len, filename, eval_flags) };
        }

        pub fn getException(self: Self) Value(RtState, CtxState) {
            return .{ .val = c.JS_GetException(self.ptr) };
        }

        pub fn _toString(self: Self, val: c.JSValueConst) [*]const u8 {
            return c.JS_ToCString(self.ptr, val);
        }
    };
}
