// JS
pub const JSValue = *anyopaque;
pub const JSValueConst = JSValue;
pub const JSModuleDef = opaque {};
pub const JSCFunction = fn (ctx: *JSContext, this: JSValue, argc: c_int, argv: [*]JSValue) ?JSValue;
pub const JSModuleNormalizeFunc = fn (*JSContext, module_base_name: [*]const u8, module_name: [*]const u8, extra: ?*anyopaque) callconv(.C) ?[*]u8;
pub const JSModuleLoaderFunc = fn (*JSContext, module_name: [*]const u8, extra: ?*anyopaque) callconv(.C) ?*JSModuleDef;

// Runtime
pub const JSRuntime = opaque {};
pub const JSMallocState = extern struct {
    malloc_count: usize,
    malloc_size: usize,
    malloc_limit: usize,
    extra: ?*anyopaque,
};
pub const JSMallocFunctions = extern struct {
    js_malloc: *const fn (*JSMallocState, usize) ?*anyopaque,
    js_free: *const fn (*JSMallocState, *anyopaque) void,
    js_realloc: *const fn (*JSMallocState, *anyopaque, usize) ?*anyopaque,
    js_malloc_usable_size: ?*const fn (*anyopaque) usize = null,
};
pub extern fn JS_NewRuntime2(mf: *const JSMallocFunctions, extra: ?*anyopaque) callconv(.C) ?*JSRuntime;
pub extern fn JS_FreeRuntime(*JSRuntime) callconv(.C) void;
pub extern fn JS_SetRuntimeOpaque(*JSRuntime, state: *anyopaque) callconv(.C) void;
pub extern fn JS_SetModuleLoaderFunc(*JSRuntime, module_normalize: ?*const JSModuleNormalizeFunc, module_loader: ?*const JSModuleLoaderFunc, extra: ?*anyopaque) callconv(.C) void;
pub extern fn JS_GetRuntimeOpaque(*JSRuntime) callconv(.C) *anyopaque;

// Context
pub const JSContext = opaque {};
pub extern fn JS_NewContext(*JSRuntime) callconv(.C) ?*JSContext;
pub extern fn JS_FreeContext(*JSContext) callconv(.C) void;
pub extern fn JS_GetRuntime(*JSContext) callconv(.C) ?JSRuntime;
pub extern fn JS_NewCFunction(*JSContext, func: *const JSCFunction, name: [*]const u8, length: c_int) callconv(.C) ?JSValue;
pub extern fn JS_GetGlobalObject(*JSContext) callconv(.C) ?JSValue;
// TODO: return type is incorrect
pub extern fn JS_SetPropertyStr(*JSContext, this: JSValueConst, prop: [*]const u8, val: JSValue) callconv(.C) ?*anyopaque;
pub extern fn JS_GetPropertyStr(*JSContext, this: JSValueConst, prop: [*]const u8) callconv(.C) ?JSValue;
pub extern fn JS_FreeValue(*JSContext, ?JSValue) callconv(.C) void;
pub extern fn JS_Eval(*JSContext, input: [*:0]u8, input_len: usize, filename: [*:0]u8, eval_flags: c_int) callconv(.C) ?JSValue;
pub extern fn JS_GetException(*JSContext) callconv(.C) ?JSValue;
pub extern fn JS_ToCString(*JSContext, val: JSValueConst) callconv(.C) [*]const u8;
