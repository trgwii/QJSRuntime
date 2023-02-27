// Runtime
const JSRuntime = opaque {};
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
extern fn JS_NewRuntime2(mf: *const JSMallocFunctions, extra: ?*anyopaque) callconv(.C) ?*JSRuntime;
extern fn JS_FreeRuntime(*JSRuntime) callconv(.C) void;

// Context
const JSContext = opaque {};
extern fn JS_NewContext(*JSRuntime) callconv(.C) ?*JSContext;
extern fn JS_FreeContext(*JSContext) callconv(.C) void;
