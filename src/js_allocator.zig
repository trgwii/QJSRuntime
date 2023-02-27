const std = @import("std");
const c = @cImport({
    @cInclude("quickjs/quickjs.h");
});

allocator: std.mem.Allocator,
sizes: std.AutoHashMapUnmanaged(usize, usize),

const Self = @This();

pub fn init(allocator: std.mem.Allocator) Self {
    return .{
        .allocator = allocator,
        .sizes = std.AutoHashMapUnmanaged(usize, usize){},
    };
}

pub fn deinit(self: *Self) void {
    self.sizes.deinit(self.allocator);
}

fn getSelf(state: ?*c.JSMallocState) *Self {
    return @ptrCast(*Self, @alignCast(@alignOf(Self), state.?.@"opaque"));
}

pub fn malloc(state: ?*c.JSMallocState, size: usize) callconv(.C) ?*anyopaque {
    const self = getSelf(state);
    self.sizes.ensureUnusedCapacity(self.allocator, 1) catch return null;
    const slice = self.allocator.alignedAlloc(u8, 16, size) catch return null;
    self.sizes.put(self.allocator, @ptrToInt(slice.ptr), size) catch unreachable;
    return slice.ptr;
}

pub fn free(state: ?*c.JSMallocState, ptr: ?*anyopaque) callconv(.C) void {
    const self = getSelf(state);
    if (ptr) |p|
        self.allocator.free(
            @ptrCast(
                [*]u8,
                p,
            )[0..if (self.sizes.fetchRemove(@ptrToInt(p))) |kv| kv.value else 1],
        );
}

pub fn realloc(state: ?*c.JSMallocState, ptr: ?*anyopaque, size: usize) callconv(.C) ?*anyopaque {
    const self = getSelf(state);
    if (ptr) |p| {
        const old_size = self.sizes.get(@ptrToInt(p)).?;
        const slice = self.allocator.realloc(@ptrCast([*]u8, p)[0..old_size], size) catch return null;
        _ = self.sizes.remove(@ptrToInt(p));
        self.sizes.put(self.allocator, @ptrToInt(slice.ptr), size) catch unreachable;
        return slice.ptr;
    } else {
        return malloc(state, size);
    }
}

pub const js_malloc_functions = c.JSMallocFunctions{
    .js_malloc = &malloc,
    .js_free = &free,
    .js_realloc = &realloc,
    .js_malloc_usable_size = null,
};
