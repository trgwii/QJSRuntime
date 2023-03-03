const std = @import("std");
const core = @import("../core.zig");
const c = @import("c.zig");
const Value = @import("Value.zig").Value;
const Runtime = @import("Runtime.zig").Runtime;
const ContextState = @import("../main.zig").ContextState;

// TODO: This should probably be replaced with a proper Value.typeOf() (Maybe returning an enum wrapping JS_TAG_* globals)
pub fn jsTagToString(tag: i64) []const u8 {
    if (tag == c.JS_TAG_FIRST) return "FIRST";
    if (tag == c.JS_TAG_BIG_DECIMAL) return "BIG_DECIMAL";
    if (tag == c.JS_TAG_BIG_INT) return "BIG_INT";
    if (tag == c.JS_TAG_BIG_FLOAT) return "BIG_FLOAT";
    if (tag == c.JS_TAG_SYMBOL) return "SYMBOL";
    if (tag == c.JS_TAG_STRING) return "STRING";
    if (tag == c.JS_TAG_MODULE) return "MODULE";
    if (tag == c.JS_TAG_FUNCTION_BYTECODE) return "FUNCTION_BYTECODE";
    if (tag == c.JS_TAG_OBJECT) return "OBJECT";
    if (tag == c.JS_TAG_INT) return "INT";
    if (tag == c.JS_TAG_BOOL) return "BOOL";
    if (tag == c.JS_TAG_NULL) return "NULL";
    if (tag == c.JS_TAG_UNDEFINED) return "UNDEFINED";
    if (tag == c.JS_TAG_UNINITIALIZED) return "UNINITIALIZED";
    if (tag == c.JS_TAG_CATCH_OFFSET) return "CATCH_OFFSET";
    if (tag == c.JS_TAG_EXCEPTION) return "EXCEPTION";
    if (tag == c.JS_TAG_FLOAT64) return "FLOAT64";
    unreachable;
}

// TODO: Support all relevant types for the wrapped function (f64 is missing, good first candidate)
pub fn createRawFunction(comptime func: anytype) c.JSCFunction {
    const info = @typeInfo(@TypeOf(func)).Fn;
    return struct {
        fn _(_ctx: ?*c.JSContext, this: c.JSValue, argc: i32, argv: ?[*]c.JSValue) callconv(.C) c.JSValue {
            const ctx = Context(void, ContextState){ .ptr = _ctx.? };
            _ = this;
            if (argc != info.params.len - 1) {
                const err = ctx.createError();
                const msg = ctx.createString("Invalid number of arguments");
                _ = err.setProp("message", msg);
                const exc = ctx.throw(err);
                return exc.val;
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
                    i32,
                    []const u8,
                    Value(void, ContextState),
                    => {
                        fields = fields ++ &[_]std.builtin.Type.StructField{.{
                            .name = comptime std.fmt.comptimePrint("{}", .{i + 1}),
                            .type = param.type.?,
                            .default_value = null,
                            .is_comptime = false,
                            .alignment = @alignOf(param.type.?),
                        }};
                    },
                    else => @compileError("Unsupported type: " ++ @typeName(param.type.?)),
                }
            }
            var params: @Type(.{ .Struct = .{
                .layout = .Auto,
                .fields = fields,
                .decls = &[_]std.builtin.Type.Declaration{},
                .is_tuple = true,
            } }) = undefined;
            params[0] = ctx;
            inline for (0..params.len - 1) |i| {
                const val: c.JSValue = argv.?[i];
                switch (@TypeOf(params[i + 1])) {
                    i32 => {
                        switch (val.tag) {
                            c.JS_TAG_INT => {
                                params[i + 1] = val.u.int32;
                            },
                            else => {
                                var buf: [256]u8 = undefined;
                                @panic(std.fmt.bufPrint(&buf, "Unsupported type: {s}\n", .{jsTagToString(val.tag)}) catch unreachable);
                            },
                        }
                    },
                    []const u8 => {
                        switch (val.tag) {
                            c.JS_TAG_STRING => params[i + 1] = std.mem.span(@ptrCast([*:0]const u8, c.JS_ToCString(ctx.ptr, val))),
                            c.JS_TAG_OBJECT => {
                                params[i + 1] = "[object Object]";
                            },
                            else => {
                                var buf: [256]u8 = undefined;
                                @panic(std.fmt.bufPrint(&buf, "Unsupported type: {s}\n", .{jsTagToString(val.tag)}) catch unreachable);
                            },
                        }
                    },
                    Value(void, ContextState) => {
                        params[i + 1] = Value(void, ContextState){ .val = val, .ctx = ctx };
                    },
                    else => @compileError("Unsupported type: " ++ @typeName(@TypeOf(params[i + 1]))),
                }
            }
            defer inline for (0..params.len - 1) |i| {
                switch (@TypeOf(params[i + 1])) {
                    []const u8 => {
                        switch (argv.?[i].tag) {
                            c.JS_TAG_STRING => c.JS_FreeCString(ctx.ptr, params[i + 1].ptr),
                            else => {},
                        }
                    },
                    i32, Value(void, ContextState) => {},
                    else => @compileError("Unsupported type: " ++ @typeName(@TypeOf(params[i + 1]))),
                }
            };

            if (info.return_type) |ReturnType| {
                switch (ReturnType) {
                    i32 => {
                        return c.JS_NewInt32(ctx.ptr, @call(.auto, func, params));
                    },
                    void, noreturn => {
                        @call(.auto, func, params);
                        return .{ .tag = c.JS_TAG_UNDEFINED, .u = .{ .ptr = null } };
                    },
                    []const u8 => {
                        const str = @call(.auto, func, params);
                        defer ctx.getState().?.allocator.free(str);
                        return ctx.createString(str).val;
                    },
                    else => @compileError("Unsupported type: " ++ @typeName(ReturnType)),
                }
            } else {
                @call(.auto, func, params);
                return .{ .tag = c.JS_TAG_UNDEFINED, .u = .{ .ptr = null } };
            }
        }
    }._;
}

const functions = b: {
    var fns: []const c.JSCFunctionListEntry = &[_]c.JSCFunctionListEntry{};
    inline for (@typeInfo(core).Struct.decls) |decl| if (decl.is_pub) {
        switch (@typeInfo(@TypeOf(@field(core, decl.name)))) {
            .Fn => |f| {
                const cFunc = createRawFunction(@field(core, decl.name));
                const param_len = f.params.len;
                fns = fns ++ &[_]c.JSCFunctionListEntry{
                    .{
                        .name = decl.name.ptr,
                        .prop_flags = c.JS_PROP_NORMAL,
                        .def_type = c.JS_DEF_CFUNC,
                        .magic = 0,
                        .u = .{ .func = .{
                            .length = param_len - 1,
                            .cproto = c.JS_CFUNC_generic,
                            .cfunc = .{ .generic = &cFunc },
                        } },
                    },
                };
            },
            .Int => {
                fns = fns ++ &[_]c.JSCFunctionListEntry{
                    .{
                        .name = decl.name.ptr,
                        .prop_flags = c.JS_PROP_NORMAL,
                        .def_type = c.JS_DEF_PROP_INT32,
                        .magic = 0,
                        .u = .{ .i32 = @field(core, decl.name) },
                    },
                };
            },
            else => @compileError("Exporting " ++ @typeName(@TypeOf(@field(core, decl.name))) ++ " to JS is not implemented"),
        }
    };
    break :b fns;
};

pub fn Context(comptime RtState: type, comptime CtxState: type) type {
    return struct {
        ptr: *c.JSContext,

        const Self = @This();
        const Rt = Runtime(RtState);
        const Val = Value(RtState, CtxState);

        pub fn init(rt: *c.JSRuntime) !Self {
            const ctx = Self{
                .ptr = c.JS_NewContext(rt) orelse return error.OutOfMemory,
            };
            const m = c.JS_NewCModule(ctx.ptr, "__core__", struct {
                fn _(_ctx: ?*c.JSContext, m: ?*c.JSModuleDef) callconv(.C) i32 {
                    std.debug.assert(c.JS_SetModuleExportList(
                        _ctx,
                        m,
                        functions.ptr,
                        @intCast(i32, functions.len),
                    ) == 0);
                    return 0;
                }
            }._);
            std.debug.assert(c.JS_AddModuleExportList(
                ctx.ptr,
                m,
                functions.ptr,
                @intCast(i32, functions.len),
            ) == 0);

            return ctx;
        }

        pub fn deinit(self: Self) void {
            c.JS_FreeContext(self.ptr);
        }

        pub fn getState(self: Self) ?*CtxState {
            return @ptrCast(
                ?*CtxState,
                @alignCast(@alignOf(CtxState), c.JS_GetContextOpaque(self.ptr)),
            );
        }

        pub fn setState(self: Self, state: *CtxState) void {
            c.JS_SetContextOpaque(self.ptr, state);
        }

        pub fn runtime(self: Self) Rt {
            return .{ .ptr = c.JS_GetRuntime(self.ptr) };
        }

        pub fn createFunction(self: Self, name: [:0]const u8, func: anytype) Val {
            const info = @typeInfo(@TypeOf(func)).Fn;
            return .{
                .val = c.JS_NewCFunction(
                    self.ptr,
                    &createRawFunction(func),
                    name.ptr,
                    info.params.len,
                ),
                .ctx = self,
            };
        }

        pub fn globalThis(self: Self) Val {
            return .{ .val = c.JS_GetGlobalObject(self.ptr), .ctx = self };
        }

        pub fn createValue(self: Self, tag: c_int, u: ?c.JSValueUnion) Val {
            return .{ .val = .{ .tag = tag, .u = u orelse .{ .ptr = null } }, .ctx = self };
        }

        pub fn createError(self: Self) Val {
            return .{ .val = c.JS_NewError(self.ptr), .ctx = self };
        }

        pub fn createString(self: Self, str: []const u8) Val {
            return .{ .val = c.JS_NewStringLen(self.ptr, str.ptr, str.len), .ctx = self };
        }

        pub fn freeString(self: Self, str: [*:0]const u8) void {
            c.JS_FreeCString(self.ptr, str);
        }

        pub fn free(self: Self, val: Val) void {
            c.JS_FreeValue(self.ptr, val.val);
        }

        // TODO: wrap eval flags with a packed struct
        pub fn eval(self: Self, input: [:0]const u8, filename: [*:0]const u8, eval_flags: i32) Val {
            return .{ .val = c.JS_Eval(self.ptr, input.ptr, input.len, filename, eval_flags), .ctx = self };
        }

        pub fn throw(self: Self, val: Val) Val {
            return .{ .val = c.JS_Throw(self.ptr, val.val), .ctx = self };
        }

        pub fn getException(self: Self) Val {
            return .{ .val = c.JS_GetException(self.ptr), .ctx = self };
        }
    };
}
