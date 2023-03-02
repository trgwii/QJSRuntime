pub const __builtin_expect = @import("std").zig.c_builtins.__builtin_expect;
pub const __off_t = c_long;
pub const __off64_t = c_long;
pub const struct__IO_marker = opaque {};
pub const _IO_lock_t = anyopaque;
pub const struct__IO_codecvt = opaque {};
pub const struct__IO_wide_data = opaque {};
pub const struct__IO_FILE = extern struct {
    _flags: c_int,
    _IO_read_ptr: [*c]u8,
    _IO_read_end: [*c]u8,
    _IO_read_base: [*c]u8,
    _IO_write_base: [*c]u8,
    _IO_write_ptr: [*c]u8,
    _IO_write_end: [*c]u8,
    _IO_buf_base: [*c]u8,
    _IO_buf_end: [*c]u8,
    _IO_save_base: [*c]u8,
    _IO_backup_base: [*c]u8,
    _IO_save_end: [*c]u8,
    _markers: ?*struct__IO_marker,
    _chain: [*c]struct__IO_FILE,
    _fileno: c_int,
    _flags2: c_int,
    _old_offset: __off_t,
    _cur_column: c_ushort,
    _vtable_offset: i8,
    _shortbuf: [1]u8,
    _lock: ?*_IO_lock_t,
    _offset: __off64_t,
    _codecvt: ?*struct__IO_codecvt,
    _wide_data: ?*struct__IO_wide_data,
    _freeres_list: [*c]struct__IO_FILE,
    _freeres_buf: ?*anyopaque,
    __pad5: usize,
    _mode: c_int,
    _unused2: [20]u8,
};
pub const FILE = struct__IO_FILE;
pub const struct_JSRuntime = opaque {};
pub const JSRuntime = struct_JSRuntime;
pub const struct_JSContext = opaque {};
pub const JSContext = struct_JSContext;
pub const struct_JSObject = opaque {};
pub const JSObject = struct_JSObject;
pub const struct_JSClass = opaque {};
pub const JSClass = struct_JSClass;
pub const JSClassID = u32;
pub const JSAtom = u32;
pub const JS_TAG_FIRST: c_int = -11;
pub const JS_TAG_BIG_DECIMAL: c_int = -11;
pub const JS_TAG_BIG_INT: c_int = -10;
pub const JS_TAG_BIG_FLOAT: c_int = -9;
pub const JS_TAG_SYMBOL: c_int = -8;
pub const JS_TAG_STRING: c_int = -7;
pub const JS_TAG_MODULE: c_int = -3;
pub const JS_TAG_FUNCTION_BYTECODE: c_int = -2;
pub const JS_TAG_OBJECT: c_int = -1;
pub const JS_TAG_INT: c_int = 0;
pub const JS_TAG_BOOL: c_int = 1;
pub const JS_TAG_NULL: c_int = 2;
pub const JS_TAG_UNDEFINED: c_int = 3;
pub const JS_TAG_UNINITIALIZED: c_int = 4;
pub const JS_TAG_CATCH_OFFSET: c_int = 5;
pub const JS_TAG_EXCEPTION: c_int = 6;
pub const JS_TAG_FLOAT64: c_int = 7;
pub const struct_JSRefCountHeader = extern struct {
    ref_count: c_int,
};
pub const JSRefCountHeader = struct_JSRefCountHeader;
pub const union_JSValueUnion = extern union {
    int32: i32,
    float64: f64,
    ptr: ?*anyopaque,
};
pub const JSValueUnion = union_JSValueUnion;
pub const struct_JSValue = extern struct {
    u: JSValueUnion,
    tag: i64,
};
pub const JSValue = struct_JSValue;
pub fn __JS_NewFloat64(arg_ctx: ?*JSContext, arg_d: f64) callconv(.C) JSValue {
    var ctx = arg_ctx;
    _ = @TypeOf(ctx);
    var d = arg_d;
    var v: JSValue = undefined;
    v.tag = @bitCast(i64, @as(c_long, JS_TAG_FLOAT64));
    v.u.float64 = d;
    return v;
}
pub fn JS_VALUE_IS_NAN(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    const union_unnamed_3 = extern union {
        d: f64,
        u64: u64,
    };
    _ = @TypeOf(union_unnamed_3);
    var u: union_unnamed_3 = undefined;
    if (v.tag != @bitCast(c_long, @as(c_long, JS_TAG_FLOAT64))) return 0;
    u.d = v.u.float64;
    return @boolToInt((u.u64 & @bitCast(c_ulong, @as(c_long, 9223372036854775807))) > @bitCast(c_ulong, @as(c_long, 9218868437227405312)));
}
pub const JSCFunction = fn (?*JSContext, JSValue, c_int, [*c]JSValue) callconv(.C) JSValue;
pub const JSCFunctionMagic = fn (?*JSContext, JSValue, c_int, [*c]JSValue, c_int) callconv(.C) JSValue;
pub const JSCFunctionData = fn (?*JSContext, JSValue, c_int, [*c]JSValue, c_int, [*c]JSValue) callconv(.C) JSValue;
pub const struct_JSMallocState = extern struct {
    malloc_count: usize,
    malloc_size: usize,
    malloc_limit: usize,
    @"opaque": ?*anyopaque,
};
pub const JSMallocState = struct_JSMallocState;
pub const struct_JSMallocFunctions = extern struct {
    js_malloc: ?*const fn ([*c]JSMallocState, usize) callconv(.C) ?*anyopaque,
    js_free: ?*const fn ([*c]JSMallocState, ?*anyopaque) callconv(.C) void,
    js_realloc: ?*const fn ([*c]JSMallocState, ?*anyopaque, usize) callconv(.C) ?*anyopaque,
    js_malloc_usable_size: ?*const fn (?*const anyopaque) callconv(.C) usize,
};
pub const JSMallocFunctions = struct_JSMallocFunctions;
pub const struct_JSGCObjectHeader = opaque {};
pub const JSGCObjectHeader = struct_JSGCObjectHeader;
pub extern fn JS_NewRuntime() ?*JSRuntime;
pub extern fn JS_SetRuntimeInfo(rt: ?*JSRuntime, info: [*c]const u8) void;
pub extern fn JS_SetMemoryLimit(rt: ?*JSRuntime, limit: usize) void;
pub extern fn JS_SetGCThreshold(rt: ?*JSRuntime, gc_threshold: usize) void;
pub extern fn JS_SetMaxStackSize(rt: ?*JSRuntime, stack_size: usize) void;
pub extern fn JS_UpdateStackTop(rt: ?*JSRuntime) void;
pub extern fn JS_NewRuntime2(mf: [*c]const JSMallocFunctions, @"opaque": ?*anyopaque) ?*JSRuntime;
pub extern fn JS_FreeRuntime(rt: ?*JSRuntime) void;
pub extern fn JS_GetRuntimeOpaque(rt: ?*JSRuntime) ?*anyopaque;
pub extern fn JS_SetRuntimeOpaque(rt: ?*JSRuntime, @"opaque": ?*anyopaque) void;
pub const JS_MarkFunc = fn (?*JSRuntime, ?*JSGCObjectHeader) callconv(.C) void;
pub extern fn JS_MarkValue(rt: ?*JSRuntime, val: JSValue, mark_func: ?*const JS_MarkFunc) void;
pub extern fn JS_RunGC(rt: ?*JSRuntime) void;
pub extern fn JS_IsLiveObject(rt: ?*JSRuntime, obj: JSValue) c_int;
pub extern fn JS_NewContext(rt: ?*JSRuntime) ?*JSContext;
pub extern fn JS_FreeContext(s: ?*JSContext) void;
pub extern fn JS_DupContext(ctx: ?*JSContext) ?*JSContext;
pub extern fn JS_GetContextOpaque(ctx: ?*JSContext) ?*anyopaque;
pub extern fn JS_SetContextOpaque(ctx: ?*JSContext, @"opaque": ?*anyopaque) void;
pub extern fn JS_GetRuntime(ctx: ?*JSContext) ?*JSRuntime;
pub extern fn JS_SetClassProto(ctx: ?*JSContext, class_id: JSClassID, obj: JSValue) void;
pub extern fn JS_GetClassProto(ctx: ?*JSContext, class_id: JSClassID) JSValue;
pub extern fn JS_NewContextRaw(rt: ?*JSRuntime) ?*JSContext;
pub extern fn JS_AddIntrinsicBaseObjects(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicDate(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicEval(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicStringNormalize(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicRegExpCompiler(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicRegExp(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicJSON(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicProxy(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicMapSet(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicTypedArrays(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicPromise(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicBigInt(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicBigFloat(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicBigDecimal(ctx: ?*JSContext) void;
pub extern fn JS_AddIntrinsicOperators(ctx: ?*JSContext) void;
pub extern fn JS_EnableBignumExt(ctx: ?*JSContext, enable: c_int) void;
pub extern fn js_string_codePointRange(ctx: ?*JSContext, this_val: JSValue, argc: c_int, argv: [*c]JSValue) JSValue;
pub extern fn js_malloc_rt(rt: ?*JSRuntime, size: usize) ?*anyopaque;
pub extern fn js_free_rt(rt: ?*JSRuntime, ptr: ?*anyopaque) void;
pub extern fn js_realloc_rt(rt: ?*JSRuntime, ptr: ?*anyopaque, size: usize) ?*anyopaque;
pub extern fn js_malloc_usable_size_rt(rt: ?*JSRuntime, ptr: ?*const anyopaque) usize;
pub extern fn js_mallocz_rt(rt: ?*JSRuntime, size: usize) ?*anyopaque;
pub extern fn js_malloc(ctx: ?*JSContext, size: usize) ?*anyopaque;
pub extern fn js_free(ctx: ?*JSContext, ptr: ?*anyopaque) void;
pub extern fn js_realloc(ctx: ?*JSContext, ptr: ?*anyopaque, size: usize) ?*anyopaque;
pub extern fn js_malloc_usable_size(ctx: ?*JSContext, ptr: ?*const anyopaque) usize;
pub extern fn js_realloc2(ctx: ?*JSContext, ptr: ?*anyopaque, size: usize, pslack: [*c]usize) ?*anyopaque;
pub extern fn js_mallocz(ctx: ?*JSContext, size: usize) ?*anyopaque;
pub extern fn js_strdup(ctx: ?*JSContext, str: [*c]const u8) [*c]u8;
pub extern fn js_strndup(ctx: ?*JSContext, s: [*c]const u8, n: usize) [*c]u8;
pub const struct_JSMemoryUsage = extern struct {
    malloc_size: i64,
    malloc_limit: i64,
    memory_used_size: i64,
    malloc_count: i64,
    memory_used_count: i64,
    atom_count: i64,
    atom_size: i64,
    str_count: i64,
    str_size: i64,
    obj_count: i64,
    obj_size: i64,
    prop_count: i64,
    prop_size: i64,
    shape_count: i64,
    shape_size: i64,
    js_func_count: i64,
    js_func_size: i64,
    js_func_code_size: i64,
    js_func_pc2line_count: i64,
    js_func_pc2line_size: i64,
    c_func_count: i64,
    array_count: i64,
    fast_array_count: i64,
    fast_array_elements: i64,
    binary_object_count: i64,
    binary_object_size: i64,
};
pub const JSMemoryUsage = struct_JSMemoryUsage;
pub extern fn JS_ComputeMemoryUsage(rt: ?*JSRuntime, s: [*c]JSMemoryUsage) void;
pub extern fn JS_DumpMemoryUsage(fp: [*c]FILE, s: [*c]const JSMemoryUsage, rt: ?*JSRuntime) void;
pub extern fn JS_NewAtomLen(ctx: ?*JSContext, str: [*c]const u8, len: usize) JSAtom;
pub extern fn JS_NewAtom(ctx: ?*JSContext, str: [*c]const u8) JSAtom;
pub extern fn JS_NewAtomUInt32(ctx: ?*JSContext, n: u32) JSAtom;
pub extern fn JS_DupAtom(ctx: ?*JSContext, v: JSAtom) JSAtom;
pub extern fn JS_FreeAtom(ctx: ?*JSContext, v: JSAtom) void;
pub extern fn JS_FreeAtomRT(rt: ?*JSRuntime, v: JSAtom) void;
pub extern fn JS_AtomToValue(ctx: ?*JSContext, atom: JSAtom) JSValue;
pub extern fn JS_AtomToString(ctx: ?*JSContext, atom: JSAtom) JSValue;
pub extern fn JS_AtomToCString(ctx: ?*JSContext, atom: JSAtom) [*c]const u8;
pub extern fn JS_ValueToAtom(ctx: ?*JSContext, val: JSValue) JSAtom;
pub const struct_JSPropertyEnum = extern struct {
    is_enumerable: c_int,
    atom: JSAtom,
};
pub const JSPropertyEnum = struct_JSPropertyEnum;
pub const struct_JSPropertyDescriptor = extern struct {
    flags: c_int,
    value: JSValue,
    getter: JSValue,
    setter: JSValue,
};
pub const JSPropertyDescriptor = struct_JSPropertyDescriptor;
pub const struct_JSClassExoticMethods = extern struct {
    get_own_property: ?*const fn (?*JSContext, [*c]JSPropertyDescriptor, JSValue, JSAtom) callconv(.C) c_int,
    get_own_property_names: ?*const fn (?*JSContext, [*c][*c]JSPropertyEnum, [*c]u32, JSValue) callconv(.C) c_int,
    delete_property: ?*const fn (?*JSContext, JSValue, JSAtom) callconv(.C) c_int,
    define_own_property: ?*const fn (?*JSContext, JSValue, JSAtom, JSValue, JSValue, JSValue, c_int) callconv(.C) c_int,
    has_property: ?*const fn (?*JSContext, JSValue, JSAtom) callconv(.C) c_int,
    get_property: ?*const fn (?*JSContext, JSValue, JSAtom, JSValue) callconv(.C) JSValue,
    set_property: ?*const fn (?*JSContext, JSValue, JSAtom, JSValue, JSValue, c_int) callconv(.C) c_int,
};
pub const JSClassExoticMethods = struct_JSClassExoticMethods;
pub const JSClassFinalizer = fn (?*JSRuntime, JSValue) callconv(.C) void;
pub const JSClassGCMark = fn (?*JSRuntime, JSValue, ?*const JS_MarkFunc) callconv(.C) void;
pub const JSClassCall = fn (?*JSContext, JSValue, JSValue, c_int, [*c]JSValue, c_int) callconv(.C) JSValue;
pub const struct_JSClassDef = extern struct {
    class_name: [*c]const u8,
    finalizer: ?*const JSClassFinalizer,
    gc_mark: ?*const JSClassGCMark,
    call: ?*const JSClassCall,
    exotic: [*c]JSClassExoticMethods,
};
pub const JSClassDef = struct_JSClassDef;
pub extern fn JS_NewClassID(pclass_id: [*c]JSClassID) JSClassID;
pub extern fn JS_NewClass(rt: ?*JSRuntime, class_id: JSClassID, class_def: [*c]const JSClassDef) c_int;
pub extern fn JS_IsRegisteredClass(rt: ?*JSRuntime, class_id: JSClassID) c_int;
pub inline fn JS_NewBool(arg_ctx: ?*JSContext, arg_val: c_int) JSValue {
    var ctx = arg_ctx;
    _ = @TypeOf(ctx);
    var val = arg_val;
    return JSValue{
        .u = JSValueUnion{
            .int32 = val != @as(c_int, 0),
        },
        .tag = @bitCast(i64, @as(c_long, JS_TAG_BOOL)),
    };
}
pub inline fn JS_NewInt32(arg_ctx: ?*JSContext, arg_val: i32) JSValue {
    var ctx = arg_ctx;
    _ = @TypeOf(ctx);
    var val = arg_val;
    return JSValue{
        .u = JSValueUnion{
            .int32 = val,
        },
        .tag = @bitCast(i64, @as(c_long, JS_TAG_INT)),
    };
}
pub inline fn JS_NewCatchOffset(arg_ctx: ?*JSContext, arg_val: i32) JSValue {
    var ctx = arg_ctx;
    _ = @TypeOf(ctx);
    var val = arg_val;
    return JSValue{
        .u = JSValueUnion{
            .int32 = val,
        },
        .tag = @bitCast(i64, @as(c_long, JS_TAG_CATCH_OFFSET)),
    };
}
pub inline fn JS_NewInt64(arg_ctx: ?*JSContext, arg_val: i64) JSValue {
    var ctx = arg_ctx;
    var val = arg_val;
    var v: JSValue = undefined;
    if (val == @bitCast(c_long, @as(c_long, @bitCast(i32, @truncate(c_int, val))))) {
        v = JS_NewInt32(ctx, @bitCast(i32, @truncate(c_int, val)));
    } else {
        v = __JS_NewFloat64(ctx, @intToFloat(f64, val));
    }
    return v;
}
pub inline fn JS_NewUint32(arg_ctx: ?*JSContext, arg_val: u32) JSValue {
    var ctx = arg_ctx;
    var val = arg_val;
    var v: JSValue = undefined;
    if (val <= @bitCast(c_uint, @as(c_int, 2147483647))) {
        v = JS_NewInt32(ctx, @bitCast(i32, val));
    } else {
        v = __JS_NewFloat64(ctx, @intToFloat(f64, val));
    }
    return v;
}
pub extern fn JS_NewBigInt64(ctx: ?*JSContext, v: i64) JSValue;
pub extern fn JS_NewBigUint64(ctx: ?*JSContext, v: u64) JSValue;
pub inline fn JS_NewFloat64(arg_ctx: ?*JSContext, arg_d: f64) JSValue {
    var ctx = arg_ctx;
    var d = arg_d;
    var v: JSValue = undefined;
    var val: i32 = undefined;
    const union_unnamed_4 = extern union {
        d: f64,
        u: u64,
    };
    _ = @TypeOf(union_unnamed_4);
    var u: union_unnamed_4 = undefined;
    var t: union_unnamed_4 = undefined;
    u.d = d;
    val = @floatToInt(i32, d);
    t.d = @intToFloat(f64, val);
    if (u.u == t.u) {
        v = JSValue{
            .u = JSValueUnion{
                .int32 = val,
            },
            .tag = @bitCast(i64, @as(c_long, JS_TAG_INT)),
        };
    } else {
        v = __JS_NewFloat64(ctx, d);
    }
    return v;
}
pub fn JS_IsNumber(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    var tag: c_int = @bitCast(i32, @truncate(c_int, v.tag));
    return @boolToInt((tag == JS_TAG_INT) or (@bitCast(c_uint, tag) == @bitCast(c_uint, JS_TAG_FLOAT64)));
}
pub fn JS_IsBigInt(arg_ctx: ?*JSContext, arg_v: JSValue) callconv(.C) c_int {
    var ctx = arg_ctx;
    _ = @TypeOf(ctx);
    var v = arg_v;
    var tag: c_int = @bitCast(i32, @truncate(c_int, v.tag));
    return @boolToInt(tag == JS_TAG_BIG_INT);
}
pub fn JS_IsBigFloat(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    var tag: c_int = @bitCast(i32, @truncate(c_int, v.tag));
    return @boolToInt(tag == JS_TAG_BIG_FLOAT);
}
pub fn JS_IsBigDecimal(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    var tag: c_int = @bitCast(i32, @truncate(c_int, v.tag));
    return @boolToInt(tag == JS_TAG_BIG_DECIMAL);
}
pub fn JS_IsBool(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    return @boolToInt(@bitCast(i32, @truncate(c_int, v.tag)) == JS_TAG_BOOL);
}
pub fn JS_IsNull(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    return @boolToInt(@bitCast(i32, @truncate(c_int, v.tag)) == JS_TAG_NULL);
}
pub fn JS_IsUndefined(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    return @boolToInt(@bitCast(i32, @truncate(c_int, v.tag)) == JS_TAG_UNDEFINED);
}
pub fn JS_IsException(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    return @bitCast(c_int, @truncate(c_int, __builtin_expect(@bitCast(c_long, @as(c_long, @boolToInt(!!(@bitCast(i32, @truncate(c_int, v.tag)) == JS_TAG_EXCEPTION)))), @bitCast(c_long, @as(c_long, @as(c_int, 0))))));
}
pub fn JS_IsUninitialized(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    return @bitCast(c_int, @truncate(c_int, __builtin_expect(@bitCast(c_long, @as(c_long, @boolToInt(!!(@bitCast(i32, @truncate(c_int, v.tag)) == JS_TAG_UNINITIALIZED)))), @bitCast(c_long, @as(c_long, @as(c_int, 0))))));
}
pub fn JS_IsString(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    return @boolToInt(@bitCast(i32, @truncate(c_int, v.tag)) == JS_TAG_STRING);
}
pub fn JS_IsSymbol(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    return @boolToInt(@bitCast(i32, @truncate(c_int, v.tag)) == JS_TAG_SYMBOL);
}
pub fn JS_IsObject(arg_v: JSValue) callconv(.C) c_int {
    var v = arg_v;
    return @boolToInt(@bitCast(i32, @truncate(c_int, v.tag)) == JS_TAG_OBJECT);
}
pub extern fn JS_Throw(ctx: ?*JSContext, obj: JSValue) JSValue;
pub extern fn JS_GetException(ctx: ?*JSContext) JSValue;
pub extern fn JS_IsError(ctx: ?*JSContext, val: JSValue) c_int;
pub extern fn JS_ResetUncatchableError(ctx: ?*JSContext) void;
pub extern fn JS_NewError(ctx: ?*JSContext) JSValue;
pub extern fn JS_ThrowSyntaxError(ctx: ?*JSContext, fmt: [*c]const u8, ...) JSValue;
pub extern fn JS_ThrowTypeError(ctx: ?*JSContext, fmt: [*c]const u8, ...) JSValue;
pub extern fn JS_ThrowReferenceError(ctx: ?*JSContext, fmt: [*c]const u8, ...) JSValue;
pub extern fn JS_ThrowRangeError(ctx: ?*JSContext, fmt: [*c]const u8, ...) JSValue;
pub extern fn JS_ThrowInternalError(ctx: ?*JSContext, fmt: [*c]const u8, ...) JSValue;
pub extern fn JS_ThrowOutOfMemory(ctx: ?*JSContext) JSValue;
pub extern fn __JS_FreeValue(ctx: ?*JSContext, v: JSValue) void;
pub fn JS_FreeValue(arg_ctx: ?*JSContext, arg_v: JSValue) callconv(.C) void {
    var ctx = arg_ctx;
    var v = arg_v;
    if (@bitCast(c_uint, @bitCast(i32, @truncate(c_int, v.tag))) >= @bitCast(c_uint, JS_TAG_FIRST)) {
        var p: [*c]JSRefCountHeader = @ptrCast([*c]JSRefCountHeader, @alignCast(@import("std").meta.alignment([*c]JSRefCountHeader), v.u.ptr));
        if ((blk: {
            const ref = &p.*.ref_count;
            ref.* -= 1;
            break :blk ref.*;
        }) <= @as(c_int, 0)) {
            __JS_FreeValue(ctx, v);
        }
    }
}
pub extern fn __JS_FreeValueRT(rt: ?*JSRuntime, v: JSValue) void;
pub fn JS_FreeValueRT(arg_rt: ?*JSRuntime, arg_v: JSValue) callconv(.C) void {
    var rt = arg_rt;
    var v = arg_v;
    if (@bitCast(c_uint, @bitCast(i32, @truncate(c_int, v.tag))) >= @bitCast(c_uint, JS_TAG_FIRST)) {
        var p: [*c]JSRefCountHeader = @ptrCast([*c]JSRefCountHeader, @alignCast(@import("std").meta.alignment([*c]JSRefCountHeader), v.u.ptr));
        if ((blk: {
            const ref = &p.*.ref_count;
            ref.* -= 1;
            break :blk ref.*;
        }) <= @as(c_int, 0)) {
            __JS_FreeValueRT(rt, v);
        }
    }
}
pub fn JS_DupValue(arg_ctx: ?*JSContext, arg_v: JSValue) callconv(.C) JSValue {
    var ctx = arg_ctx;
    _ = @TypeOf(ctx);
    var v = arg_v;
    if (@bitCast(c_uint, @bitCast(i32, @truncate(c_int, v.tag))) >= @bitCast(c_uint, JS_TAG_FIRST)) {
        var p: [*c]JSRefCountHeader = @ptrCast([*c]JSRefCountHeader, @alignCast(@import("std").meta.alignment([*c]JSRefCountHeader), v.u.ptr));
        p.*.ref_count += 1;
    }
    return v;
}
pub fn JS_DupValueRT(arg_rt: ?*JSRuntime, arg_v: JSValue) callconv(.C) JSValue {
    var rt = arg_rt;
    _ = @TypeOf(rt);
    var v = arg_v;
    if (@bitCast(c_uint, @bitCast(i32, @truncate(c_int, v.tag))) >= @bitCast(c_uint, JS_TAG_FIRST)) {
        var p: [*c]JSRefCountHeader = @ptrCast([*c]JSRefCountHeader, @alignCast(@import("std").meta.alignment([*c]JSRefCountHeader), v.u.ptr));
        p.*.ref_count += 1;
    }
    return v;
}
pub extern fn JS_ToBool(ctx: ?*JSContext, val: JSValue) c_int;
pub extern fn JS_ToInt32(ctx: ?*JSContext, pres: [*c]i32, val: JSValue) c_int;
pub fn JS_ToUint32(arg_ctx: ?*JSContext, arg_pres: [*c]u32, arg_val: JSValue) callconv(.C) c_int {
    var ctx = arg_ctx;
    var pres = arg_pres;
    var val = arg_val;
    return JS_ToInt32(ctx, @ptrCast([*c]i32, @alignCast(@import("std").meta.alignment([*c]i32), pres)), val);
}
pub extern fn JS_ToInt64(ctx: ?*JSContext, pres: [*c]i64, val: JSValue) c_int;
pub extern fn JS_ToIndex(ctx: ?*JSContext, plen: [*c]u64, val: JSValue) c_int;
pub extern fn JS_ToFloat64(ctx: ?*JSContext, pres: [*c]f64, val: JSValue) c_int;
pub extern fn JS_ToBigInt64(ctx: ?*JSContext, pres: [*c]i64, val: JSValue) c_int;
pub extern fn JS_ToInt64Ext(ctx: ?*JSContext, pres: [*c]i64, val: JSValue) c_int;
pub extern fn JS_NewStringLen(ctx: ?*JSContext, str1: [*c]const u8, len1: usize) JSValue;
pub extern fn JS_NewString(ctx: ?*JSContext, str: [*c]const u8) JSValue;
pub extern fn JS_NewAtomString(ctx: ?*JSContext, str: [*c]const u8) JSValue;
pub extern fn JS_ToString(ctx: ?*JSContext, val: JSValue) JSValue;
pub extern fn JS_ToPropertyKey(ctx: ?*JSContext, val: JSValue) JSValue;
pub extern fn JS_ToCStringLen2(ctx: ?*JSContext, plen: [*c]usize, val1: JSValue, cesu8: c_int) [*c]const u8;
pub fn JS_ToCStringLen(arg_ctx: ?*JSContext, arg_plen: [*c]usize, arg_val1: JSValue) callconv(.C) [*c]const u8 {
    var ctx = arg_ctx;
    var plen = arg_plen;
    var val1 = arg_val1;
    return JS_ToCStringLen2(ctx, plen, val1, @as(c_int, 0));
}
pub fn JS_ToCString(arg_ctx: ?*JSContext, arg_val1: JSValue) callconv(.C) [*c]const u8 {
    var ctx = arg_ctx;
    var val1 = arg_val1;
    return JS_ToCStringLen2(ctx, null, val1, @as(c_int, 0));
}
pub extern fn JS_FreeCString(ctx: ?*JSContext, ptr: [*c]const u8) void;
pub extern fn JS_NewObjectProtoClass(ctx: ?*JSContext, proto: JSValue, class_id: JSClassID) JSValue;
pub extern fn JS_NewObjectClass(ctx: ?*JSContext, class_id: c_int) JSValue;
pub extern fn JS_NewObjectProto(ctx: ?*JSContext, proto: JSValue) JSValue;
pub extern fn JS_NewObject(ctx: ?*JSContext) JSValue;
pub extern fn JS_IsFunction(ctx: ?*JSContext, val: JSValue) c_int;
pub extern fn JS_IsConstructor(ctx: ?*JSContext, val: JSValue) c_int;
pub extern fn JS_SetConstructorBit(ctx: ?*JSContext, func_obj: JSValue, val: c_int) c_int;
pub extern fn JS_NewArray(ctx: ?*JSContext) JSValue;
pub extern fn JS_IsArray(ctx: ?*JSContext, val: JSValue) c_int;
pub extern fn JS_GetPropertyInternal(ctx: ?*JSContext, obj: JSValue, prop: JSAtom, receiver: JSValue, throw_ref_error: c_int) JSValue;
pub inline fn JS_GetProperty(arg_ctx: ?*JSContext, arg_this_obj: JSValue, arg_prop: JSAtom) JSValue {
    var ctx = arg_ctx;
    var this_obj = arg_this_obj;
    var prop = arg_prop;
    return JS_GetPropertyInternal(ctx, this_obj, prop, this_obj, @as(c_int, 0));
}
pub extern fn JS_GetPropertyStr(ctx: ?*JSContext, this_obj: JSValue, prop: [*c]const u8) JSValue;
pub extern fn JS_GetPropertyUint32(ctx: ?*JSContext, this_obj: JSValue, idx: u32) JSValue;
pub extern fn JS_SetPropertyInternal(ctx: ?*JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue, flags: c_int) c_int;
pub fn JS_SetProperty(arg_ctx: ?*JSContext, arg_this_obj: JSValue, arg_prop: JSAtom, arg_val: JSValue) callconv(.C) c_int {
    var ctx = arg_ctx;
    var this_obj = arg_this_obj;
    var prop = arg_prop;
    var val = arg_val;
    return JS_SetPropertyInternal(ctx, this_obj, prop, val, @as(c_int, 1) << @intCast(@import("std").math.Log2Int(c_int), 14));
}
pub extern fn JS_SetPropertyUint32(ctx: ?*JSContext, this_obj: JSValue, idx: u32, val: JSValue) c_int;
pub extern fn JS_SetPropertyInt64(ctx: ?*JSContext, this_obj: JSValue, idx: i64, val: JSValue) c_int;
pub extern fn JS_SetPropertyStr(ctx: ?*JSContext, this_obj: JSValue, prop: [*c]const u8, val: JSValue) c_int;
pub extern fn JS_HasProperty(ctx: ?*JSContext, this_obj: JSValue, prop: JSAtom) c_int;
pub extern fn JS_IsExtensible(ctx: ?*JSContext, obj: JSValue) c_int;
pub extern fn JS_PreventExtensions(ctx: ?*JSContext, obj: JSValue) c_int;
pub extern fn JS_DeleteProperty(ctx: ?*JSContext, obj: JSValue, prop: JSAtom, flags: c_int) c_int;
pub extern fn JS_SetPrototype(ctx: ?*JSContext, obj: JSValue, proto_val: JSValue) c_int;
pub extern fn JS_GetPrototype(ctx: ?*JSContext, val: JSValue) JSValue;
pub extern fn JS_GetOwnPropertyNames(ctx: ?*JSContext, ptab: [*c][*c]JSPropertyEnum, plen: [*c]u32, obj: JSValue, flags: c_int) c_int;
pub extern fn JS_GetOwnProperty(ctx: ?*JSContext, desc: [*c]JSPropertyDescriptor, obj: JSValue, prop: JSAtom) c_int;
pub extern fn JS_Call(ctx: ?*JSContext, func_obj: JSValue, this_obj: JSValue, argc: c_int, argv: [*c]JSValue) JSValue;
pub extern fn JS_Invoke(ctx: ?*JSContext, this_val: JSValue, atom: JSAtom, argc: c_int, argv: [*c]JSValue) JSValue;
pub extern fn JS_CallConstructor(ctx: ?*JSContext, func_obj: JSValue, argc: c_int, argv: [*c]JSValue) JSValue;
pub extern fn JS_CallConstructor2(ctx: ?*JSContext, func_obj: JSValue, new_target: JSValue, argc: c_int, argv: [*c]JSValue) JSValue;
pub extern fn JS_DetectModule(input: [*c]const u8, input_len: usize) c_int;
pub extern fn JS_Eval(ctx: ?*JSContext, input: [*c]const u8, input_len: usize, filename: [*c]const u8, eval_flags: c_int) JSValue;
pub extern fn JS_EvalThis(ctx: ?*JSContext, this_obj: JSValue, input: [*c]const u8, input_len: usize, filename: [*c]const u8, eval_flags: c_int) JSValue;
pub extern fn JS_GetGlobalObject(ctx: ?*JSContext) JSValue;
pub extern fn JS_IsInstanceOf(ctx: ?*JSContext, val: JSValue, obj: JSValue) c_int;
pub extern fn JS_DefineProperty(ctx: ?*JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue, getter: JSValue, setter: JSValue, flags: c_int) c_int;
pub extern fn JS_DefinePropertyValue(ctx: ?*JSContext, this_obj: JSValue, prop: JSAtom, val: JSValue, flags: c_int) c_int;
pub extern fn JS_DefinePropertyValueUint32(ctx: ?*JSContext, this_obj: JSValue, idx: u32, val: JSValue, flags: c_int) c_int;
pub extern fn JS_DefinePropertyValueStr(ctx: ?*JSContext, this_obj: JSValue, prop: [*c]const u8, val: JSValue, flags: c_int) c_int;
pub extern fn JS_DefinePropertyGetSet(ctx: ?*JSContext, this_obj: JSValue, prop: JSAtom, getter: JSValue, setter: JSValue, flags: c_int) c_int;
pub extern fn JS_SetOpaque(obj: JSValue, @"opaque": ?*anyopaque) void;
pub extern fn JS_GetOpaque(obj: JSValue, class_id: JSClassID) ?*anyopaque;
pub extern fn JS_GetOpaque2(ctx: ?*JSContext, obj: JSValue, class_id: JSClassID) ?*anyopaque;
pub extern fn JS_ParseJSON(ctx: ?*JSContext, buf: [*c]const u8, buf_len: usize, filename: [*c]const u8) JSValue;
pub extern fn JS_ParseJSON2(ctx: ?*JSContext, buf: [*c]const u8, buf_len: usize, filename: [*c]const u8, flags: c_int) JSValue;
pub extern fn JS_JSONStringify(ctx: ?*JSContext, obj: JSValue, replacer: JSValue, space0: JSValue) JSValue;
pub const JSFreeArrayBufferDataFunc = fn (?*JSRuntime, ?*anyopaque, ?*anyopaque) callconv(.C) void;
pub extern fn JS_NewArrayBuffer(ctx: ?*JSContext, buf: [*c]u8, len: usize, free_func: ?*const JSFreeArrayBufferDataFunc, @"opaque": ?*anyopaque, is_shared: c_int) JSValue;
pub extern fn JS_NewArrayBufferCopy(ctx: ?*JSContext, buf: [*c]const u8, len: usize) JSValue;
pub extern fn JS_DetachArrayBuffer(ctx: ?*JSContext, obj: JSValue) void;
pub extern fn JS_GetArrayBuffer(ctx: ?*JSContext, psize: [*c]usize, obj: JSValue) [*c]u8;
pub extern fn JS_GetTypedArrayBuffer(ctx: ?*JSContext, obj: JSValue, pbyte_offset: [*c]usize, pbyte_length: [*c]usize, pbytes_per_element: [*c]usize) JSValue;
pub const JSSharedArrayBufferFunctions = extern struct {
    sab_alloc: ?*const fn (?*anyopaque, usize) callconv(.C) ?*anyopaque,
    sab_free: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void,
    sab_dup: ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) void,
    sab_opaque: ?*anyopaque,
};
pub extern fn JS_SetSharedArrayBufferFunctions(rt: ?*JSRuntime, sf: [*c]const JSSharedArrayBufferFunctions) void;
pub extern fn JS_NewPromiseCapability(ctx: ?*JSContext, resolving_funcs: [*c]JSValue) JSValue;
pub const JSHostPromiseRejectionTracker = fn (?*JSContext, JSValue, JSValue, c_int, ?*anyopaque) callconv(.C) void;
pub extern fn JS_SetHostPromiseRejectionTracker(rt: ?*JSRuntime, cb: ?*const JSHostPromiseRejectionTracker, @"opaque": ?*anyopaque) void;
pub const JSInterruptHandler = fn (?*JSRuntime, ?*anyopaque) callconv(.C) c_int;
pub extern fn JS_SetInterruptHandler(rt: ?*JSRuntime, cb: ?*const JSInterruptHandler, @"opaque": ?*anyopaque) void;
pub extern fn JS_SetCanBlock(rt: ?*JSRuntime, can_block: c_int) void;
pub extern fn JS_SetIsHTMLDDA(ctx: ?*JSContext, obj: JSValue) void;
pub const struct_JSModuleDef = opaque {};
pub const JSModuleDef = struct_JSModuleDef;
pub const JSModuleNormalizeFunc = fn (?*JSContext, [*c]const u8, [*c]const u8, ?*anyopaque) callconv(.C) [*c]u8;
pub const JSModuleLoaderFunc = fn (?*JSContext, [*c]const u8, ?*anyopaque) callconv(.C) ?*JSModuleDef;
pub extern fn JS_SetModuleLoaderFunc(rt: ?*JSRuntime, module_normalize: ?*const JSModuleNormalizeFunc, module_loader: ?*const JSModuleLoaderFunc, @"opaque": ?*anyopaque) void;
pub extern fn JS_GetImportMeta(ctx: ?*JSContext, m: ?*JSModuleDef) JSValue;
pub extern fn JS_GetModuleName(ctx: ?*JSContext, m: ?*JSModuleDef) JSAtom;
pub const JSJobFunc = fn (?*JSContext, c_int, [*c]JSValue) callconv(.C) JSValue;
pub extern fn JS_EnqueueJob(ctx: ?*JSContext, job_func: ?*const JSJobFunc, argc: c_int, argv: [*c]JSValue) c_int;
pub extern fn JS_IsJobPending(rt: ?*JSRuntime) c_int;
pub extern fn JS_ExecutePendingJob(rt: ?*JSRuntime, pctx: [*c]?*JSContext) c_int;
pub extern fn JS_WriteObject(ctx: ?*JSContext, psize: [*c]usize, obj: JSValue, flags: c_int) [*c]u8;
pub extern fn JS_WriteObject2(ctx: ?*JSContext, psize: [*c]usize, obj: JSValue, flags: c_int, psab_tab: [*c][*c][*c]u8, psab_tab_len: [*c]usize) [*c]u8;
pub extern fn JS_ReadObject(ctx: ?*JSContext, buf: [*c]const u8, buf_len: usize, flags: c_int) JSValue;
pub extern fn JS_EvalFunction(ctx: ?*JSContext, fun_obj: JSValue) JSValue;
pub extern fn JS_ResolveModule(ctx: ?*JSContext, obj: JSValue) c_int;
pub extern fn JS_GetScriptOrModuleName(ctx: ?*JSContext, n_stack_levels: c_int) JSAtom;
pub extern fn JS_RunModule(ctx: ?*JSContext, basename: [*c]const u8, filename: [*c]const u8) ?*JSModuleDef;
pub const JS_CFUNC_generic: c_int = 0;
pub const JS_CFUNC_generic_magic: c_int = 1;
pub const JS_CFUNC_constructor: c_int = 2;
pub const JS_CFUNC_constructor_magic: c_int = 3;
pub const JS_CFUNC_constructor_or_func: c_int = 4;
pub const JS_CFUNC_constructor_or_func_magic: c_int = 5;
pub const JS_CFUNC_f_f: c_int = 6;
pub const JS_CFUNC_f_f_f: c_int = 7;
pub const JS_CFUNC_getter: c_int = 8;
pub const JS_CFUNC_setter: c_int = 9;
pub const JS_CFUNC_getter_magic: c_int = 10;
pub const JS_CFUNC_setter_magic: c_int = 11;
pub const JS_CFUNC_iterator_next: c_int = 12;
pub const enum_JSCFunctionEnum = c_uint;
pub const JSCFunctionEnum = enum_JSCFunctionEnum;
pub const union_JSCFunctionType = extern union {
    generic: ?*const JSCFunction,
    generic_magic: ?*const fn (?*JSContext, JSValue, c_int, [*c]JSValue, c_int) callconv(.C) JSValue,
    constructor: ?*const JSCFunction,
    constructor_magic: ?*const fn (?*JSContext, JSValue, c_int, [*c]JSValue, c_int) callconv(.C) JSValue,
    constructor_or_func: ?*const JSCFunction,
    f_f: ?*const fn (f64) callconv(.C) f64,
    f_f_f: ?*const fn (f64, f64) callconv(.C) f64,
    getter: ?*const fn (?*JSContext, JSValue) callconv(.C) JSValue,
    setter: ?*const fn (?*JSContext, JSValue, JSValue) callconv(.C) JSValue,
    getter_magic: ?*const fn (?*JSContext, JSValue, c_int) callconv(.C) JSValue,
    setter_magic: ?*const fn (?*JSContext, JSValue, JSValue, c_int) callconv(.C) JSValue,
    iterator_next: ?*const fn (?*JSContext, JSValue, c_int, [*c]JSValue, [*c]c_int, c_int) callconv(.C) JSValue,
};
pub const JSCFunctionType = union_JSCFunctionType;
pub extern fn JS_NewCFunction2(ctx: ?*JSContext, func: ?*const JSCFunction, name: [*c]const u8, length: c_int, cproto: JSCFunctionEnum, magic: c_int) JSValue;
pub extern fn JS_NewCFunctionData(ctx: ?*JSContext, func: ?*const JSCFunctionData, length: c_int, magic: c_int, data_len: c_int, data: [*c]JSValue) JSValue;
pub fn JS_NewCFunction(arg_ctx: ?*JSContext, arg_func: ?*const JSCFunction, arg_name: [*c]const u8, arg_length: c_int) callconv(.C) JSValue {
    var ctx = arg_ctx;
    var func = arg_func;
    var name = arg_name;
    var length = arg_length;
    return JS_NewCFunction2(ctx, func, name, length, @bitCast(c_uint, JS_CFUNC_generic), @as(c_int, 0));
}
pub fn JS_NewCFunctionMagic(arg_ctx: ?*JSContext, arg_func: ?*const JSCFunctionMagic, arg_name: [*c]const u8, arg_length: c_int, arg_cproto: JSCFunctionEnum, arg_magic: c_int) callconv(.C) JSValue {
    var ctx = arg_ctx;
    var func = arg_func;
    var name = arg_name;
    var length = arg_length;
    var cproto = arg_cproto;
    var magic = arg_magic;
    return JS_NewCFunction2(ctx, @ptrCast(?*const JSCFunction, @alignCast(@import("std").meta.alignment(?*const JSCFunction), func)), name, length, cproto, magic);
}
pub extern fn JS_SetConstructor(ctx: ?*JSContext, func_obj: JSValue, proto: JSValue) void;
const struct_unnamed_6 = extern struct {
    length: u8,
    cproto: u8,
    cfunc: JSCFunctionType,
};
const struct_unnamed_7 = extern struct {
    get: JSCFunctionType,
    set: JSCFunctionType,
};
const struct_unnamed_8 = extern struct {
    name: [*c]const u8,
    base: c_int,
};
const struct_unnamed_9 = extern struct {
    tab: [*c]const struct_JSCFunctionListEntry,
    len: c_int,
};
const union_unnamed_5 = extern union {
    func: struct_unnamed_6,
    getset: struct_unnamed_7,
    alias: struct_unnamed_8,
    prop_list: struct_unnamed_9,
    str: [*c]const u8,
    i32: i32,
    i64: i64,
    f64: f64,
};
pub const struct_JSCFunctionListEntry = extern struct {
    name: [*c]const u8,
    prop_flags: u8,
    def_type: u8,
    magic: i16,
    u: union_unnamed_5,
};
pub const JSCFunctionListEntry = struct_JSCFunctionListEntry;
pub extern fn JS_SetPropertyFunctionList(ctx: ?*JSContext, obj: JSValue, tab: [*c]const JSCFunctionListEntry, len: c_int) void;
pub const JSModuleInitFunc = fn (?*JSContext, ?*JSModuleDef) callconv(.C) c_int;
pub extern fn JS_NewCModule(ctx: ?*JSContext, name_str: [*c]const u8, func: ?*const JSModuleInitFunc) ?*JSModuleDef;
pub extern fn JS_AddModuleExport(ctx: ?*JSContext, m: ?*JSModuleDef, name_str: [*c]const u8) c_int;
pub extern fn JS_AddModuleExportList(ctx: ?*JSContext, m: ?*JSModuleDef, tab: [*c]const JSCFunctionListEntry, len: c_int) c_int;
pub extern fn JS_SetModuleExport(ctx: ?*JSContext, m: ?*JSModuleDef, export_name: [*c]const u8, val: JSValue) c_int;
pub extern fn JS_SetModuleExportList(ctx: ?*JSContext, m: ?*JSModuleDef, tab: [*c]const JSCFunctionListEntry, len: c_int) c_int;
pub const JS_FLOAT64_NAN = @compileError("unable to translate macro: undefined identifier `NAN`"); // deps/quickjs/quickjs.h:94:9
pub const JS_NAN = @compileError("unable to translate C expr: expected '=' instead got '.'"); // deps/quickjs/quickjs.h:223:9
pub const JS_VALUE_GET_STRING = @compileError("unable to translate macro: undefined identifier `JSString`"); // deps/quickjs/quickjs.h:251:9
pub const JS_CFUNC_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1007:9
pub const JS_CFUNC_MAGIC_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1008:9
pub const JS_CFUNC_SPECIAL_DEF = @compileError("unable to translate macro: undefined identifier `JS_CFUNC_`"); // deps/quickjs/quickjs.h:1009:9
pub const JS_ITERATOR_NEXT_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1010:9
pub const JS_CGETSET_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1011:9
pub const JS_CGETSET_MAGIC_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1012:9
pub const JS_PROP_STRING_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1013:9
pub const JS_PROP_INT32_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1014:9
pub const JS_PROP_INT64_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1015:9
pub const JS_PROP_DOUBLE_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1016:9
pub const JS_PROP_UNDEFINED_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1017:9
pub const JS_OBJECT_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1018:9
pub const JS_ALIAS_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1019:9
pub const JS_ALIAS_BASE_DEF = @compileError("unable to translate C expr: unexpected token '{'"); // deps/quickjs/quickjs.h:1020:9
pub inline fn js_likely(x: anytype) @TypeOf(__builtin_expect(!!(x != 0), @as(c_int, 1))) {
    return __builtin_expect(!!(x != 0), @as(c_int, 1));
}
pub inline fn js_unlikely(x: anytype) @TypeOf(__builtin_expect(!!(x != 0), @as(c_int, 0))) {
    return __builtin_expect(!!(x != 0), @as(c_int, 0));
}
pub const JS_BOOL = c_int;
pub const JS_PTR64 = "";
pub inline fn JS_PTR64_DEF(a: anytype) @TypeOf(a) {
    return a;
}
pub const JSValueConst = JSValue;
pub inline fn JS_VALUE_GET_TAG(v: anytype) i32 {
    return @import("std").zig.c_translation.cast(i32, v.tag);
}
pub inline fn JS_VALUE_GET_NORM_TAG(v: anytype) @TypeOf(JS_VALUE_GET_TAG(v)) {
    return JS_VALUE_GET_TAG(v);
}
pub inline fn JS_VALUE_GET_INT(v: anytype) @TypeOf(v.u.int32) {
    return v.u.int32;
}
pub inline fn JS_VALUE_GET_BOOL(v: anytype) @TypeOf(v.u.int32) {
    return v.u.int32;
}
pub inline fn JS_VALUE_GET_FLOAT64(v: anytype) @TypeOf(v.u.float64) {
    return v.u.float64;
}
pub inline fn JS_VALUE_GET_PTR(v: anytype) @TypeOf(v.u.ptr) {
    return v.u.ptr;
}
pub inline fn JS_MKVAL(tag: anytype, val: anytype) JSValue {
    return @import("std").mem.zeroInit(JSValue, .{ @import("std").mem.zeroInit(JSValueUnion, .{
        .int32 = val,
    }), tag });
}
pub inline fn JS_MKPTR(tag: anytype, p: anytype) JSValue {
    return @import("std").mem.zeroInit(JSValue, .{ @import("std").mem.zeroInit(JSValueUnion, .{
        .ptr = p,
    }), tag });
}
pub inline fn JS_TAG_IS_FLOAT64(tag: anytype) @TypeOf(@import("std").zig.c_translation.cast(c_uint, tag) == JS_TAG_FLOAT64) {
    return @import("std").zig.c_translation.cast(c_uint, tag) == JS_TAG_FLOAT64;
}
pub inline fn JS_VALUE_IS_BOTH_INT(v1: anytype, v2: anytype) @TypeOf((JS_VALUE_GET_TAG(v1) | JS_VALUE_GET_TAG(v2)) == @as(c_int, 0)) {
    return (JS_VALUE_GET_TAG(v1) | JS_VALUE_GET_TAG(v2)) == @as(c_int, 0);
}
pub inline fn JS_VALUE_IS_BOTH_FLOAT(v1: anytype, v2: anytype) @TypeOf((JS_TAG_IS_FLOAT64(JS_VALUE_GET_TAG(v1)) != 0) and (JS_TAG_IS_FLOAT64(JS_VALUE_GET_TAG(v2)) != 0)) {
    return (JS_TAG_IS_FLOAT64(JS_VALUE_GET_TAG(v1)) != 0) and (JS_TAG_IS_FLOAT64(JS_VALUE_GET_TAG(v2)) != 0);
}
pub inline fn JS_VALUE_GET_OBJ(v: anytype) [*c]JSObject {
    return @import("std").zig.c_translation.cast([*c]JSObject, JS_VALUE_GET_PTR(v));
}
pub inline fn JS_VALUE_HAS_REF_COUNT(v: anytype) @TypeOf(@import("std").zig.c_translation.cast(c_uint, JS_VALUE_GET_TAG(v)) >= @import("std").zig.c_translation.cast(c_uint, JS_TAG_FIRST)) {
    return @import("std").zig.c_translation.cast(c_uint, JS_VALUE_GET_TAG(v)) >= @import("std").zig.c_translation.cast(c_uint, JS_TAG_FIRST);
}
pub const JS_NULL = JS_MKVAL(JS_TAG_NULL, @as(c_int, 0));
pub const JS_UNDEFINED = JS_MKVAL(JS_TAG_UNDEFINED, @as(c_int, 0));
pub const JS_FALSE = JS_MKVAL(JS_TAG_BOOL, @as(c_int, 0));
pub const JS_TRUE = JS_MKVAL(JS_TAG_BOOL, @as(c_int, 1));
pub const JS_EXCEPTION = JS_MKVAL(JS_TAG_EXCEPTION, @as(c_int, 0));
pub const JS_UNINITIALIZED = JS_MKVAL(JS_TAG_UNINITIALIZED, @as(c_int, 0));
pub const JS_PROP_CONFIGURABLE = @as(c_int, 1) << @as(c_int, 0);
pub const JS_PROP_WRITABLE = @as(c_int, 1) << @as(c_int, 1);
pub const JS_PROP_ENUMERABLE = @as(c_int, 1) << @as(c_int, 2);
pub const JS_PROP_C_W_E = (JS_PROP_CONFIGURABLE | JS_PROP_WRITABLE) | JS_PROP_ENUMERABLE;
pub const JS_PROP_LENGTH = @as(c_int, 1) << @as(c_int, 3);
pub const JS_PROP_TMASK = @as(c_int, 3) << @as(c_int, 4);
pub const JS_PROP_NORMAL = @as(c_int, 0) << @as(c_int, 4);
pub const JS_PROP_GETSET = @as(c_int, 1) << @as(c_int, 4);
pub const JS_PROP_VARREF = @as(c_int, 2) << @as(c_int, 4);
pub const JS_PROP_AUTOINIT = @as(c_int, 3) << @as(c_int, 4);
pub const JS_PROP_HAS_SHIFT = @as(c_int, 8);
pub const JS_PROP_HAS_CONFIGURABLE = @as(c_int, 1) << @as(c_int, 8);
pub const JS_PROP_HAS_WRITABLE = @as(c_int, 1) << @as(c_int, 9);
pub const JS_PROP_HAS_ENUMERABLE = @as(c_int, 1) << @as(c_int, 10);
pub const JS_PROP_HAS_GET = @as(c_int, 1) << @as(c_int, 11);
pub const JS_PROP_HAS_SET = @as(c_int, 1) << @as(c_int, 12);
pub const JS_PROP_HAS_VALUE = @as(c_int, 1) << @as(c_int, 13);
pub const JS_PROP_THROW = @as(c_int, 1) << @as(c_int, 14);
pub const JS_PROP_THROW_STRICT = @as(c_int, 1) << @as(c_int, 15);
pub const JS_PROP_NO_ADD = @as(c_int, 1) << @as(c_int, 16);
pub const JS_PROP_NO_EXOTIC = @as(c_int, 1) << @as(c_int, 17);
pub const JS_DEFAULT_STACK_SIZE = @as(c_int, 256) * @as(c_int, 1024);
pub const JS_EVAL_TYPE_GLOBAL = @as(c_int, 0) << @as(c_int, 0);
pub const JS_EVAL_TYPE_MODULE = @as(c_int, 1) << @as(c_int, 0);
pub const JS_EVAL_TYPE_DIRECT = @as(c_int, 2) << @as(c_int, 0);
pub const JS_EVAL_TYPE_INDIRECT = @as(c_int, 3) << @as(c_int, 0);
pub const JS_EVAL_TYPE_MASK = @as(c_int, 3) << @as(c_int, 0);
pub const JS_EVAL_FLAG_STRICT = @as(c_int, 1) << @as(c_int, 3);
pub const JS_EVAL_FLAG_STRIP = @as(c_int, 1) << @as(c_int, 4);
pub const JS_EVAL_FLAG_COMPILE_ONLY = @as(c_int, 1) << @as(c_int, 5);
pub const JS_EVAL_FLAG_BACKTRACE_BARRIER = @as(c_int, 1) << @as(c_int, 6);
pub const JS_ATOM_NULL = @as(c_int, 0);
pub const JS_CALL_FLAG_CONSTRUCTOR = @as(c_int, 1) << @as(c_int, 0);
pub const JS_GPN_STRING_MASK = @as(c_int, 1) << @as(c_int, 0);
pub const JS_GPN_SYMBOL_MASK = @as(c_int, 1) << @as(c_int, 1);
pub const JS_GPN_PRIVATE_MASK = @as(c_int, 1) << @as(c_int, 2);
pub const JS_GPN_ENUM_ONLY = @as(c_int, 1) << @as(c_int, 4);
pub const JS_GPN_SET_ENUM = @as(c_int, 1) << @as(c_int, 5);
pub const JS_PARSE_JSON_EXT = @as(c_int, 1) << @as(c_int, 0);
pub const JS_WRITE_OBJ_BYTECODE = @as(c_int, 1) << @as(c_int, 0);
pub const JS_WRITE_OBJ_BSWAP = @as(c_int, 1) << @as(c_int, 1);
pub const JS_WRITE_OBJ_SAB = @as(c_int, 1) << @as(c_int, 2);
pub const JS_WRITE_OBJ_REFERENCE = @as(c_int, 1) << @as(c_int, 3);
pub const JS_READ_OBJ_BYTECODE = @as(c_int, 1) << @as(c_int, 0);
pub const JS_READ_OBJ_ROM_DATA = @as(c_int, 1) << @as(c_int, 1);
pub const JS_READ_OBJ_SAB = @as(c_int, 1) << @as(c_int, 2);
pub const JS_READ_OBJ_REFERENCE = @as(c_int, 1) << @as(c_int, 3);
pub const JS_DEF_CFUNC = @as(c_int, 0);
pub const JS_DEF_CGETSET = @as(c_int, 1);
pub const JS_DEF_CGETSET_MAGIC = @as(c_int, 2);
pub const JS_DEF_PROP_STRING = @as(c_int, 3);
pub const JS_DEF_PROP_INT32 = @as(c_int, 4);
pub const JS_DEF_PROP_INT64 = @as(c_int, 5);
pub const JS_DEF_PROP_DOUBLE = @as(c_int, 6);
pub const JS_DEF_PROP_UNDEFINED = @as(c_int, 7);
pub const JS_DEF_OBJECT = @as(c_int, 8);
pub const JS_DEF_ALIAS = @as(c_int, 9);
