const std = @import("std");
const c = @import("c.zig");

pub const AllocatorState = struct {
    allocator: std.mem.Allocator,
    sizes: std.AutoHashMapUnmanaged(usize, usize) = std.AutoHashMapUnmanaged(usize, usize){},
};

fn toAllocatorState(s: *c.JSMallocState) *AllocatorState {
    return @ptrCast(
        *AllocatorState,
        @alignCast(
            @alignOf(AllocatorState),
            s.extra.?,
        ),
    );
}

fn js_malloc(s: *c.JSMallocState, size: usize) ?*anyopaque {
    const as = toAllocatorState(s);
    if (size == 0) return null;
    as.sizes.ensureUnusedCapacity(as.allocator, 1) catch return null;
    const slice = as.allocator.alignedAlloc(u8, 16, size) catch return null;
    const addr = @ptrToInt(slice.ptr);
    as.sizes.put(as.allocator, addr, size) catch unreachable;
    return slice.ptr;
}

fn js_free(s: *c.JSMallocState, ptr: ?*anyopaque) void {
    const as = toAllocatorState(s);
    if (ptr) |p| {
        const addr = @ptrToInt(p);
        if (as.sizes.fetchRemove(addr)) |kv| {
            as.allocator.free(@intToPtr([*]u8, addr)[0..kv.value]);
        }
    }
}

fn js_realloc(s: *c.JSMallocState, ptr: ?*anyopaque, size: usize) ?*anyopaque {
    const as = toAllocatorState(s);
    if (ptr) |p| {
        if (size == 0) return js_free(s, p);
        const addr = @ptrToInt(p);
        if (as.sizes.get(addr)) |old_size| {
            as.sizes.ensureUnusedCapacity(as.allocator, 1) catch return null;
            const slice = as.allocator.realloc(@intToPtr([*]u8, addr)[0..old_size], size) catch return null;
            if (@ptrToInt(slice.ptr) != addr) {
                as.sizes.remove(addr);
            }
            as.sizes.put(as.allocator, @ptrToInt(slice.ptr), size) catch unreachable;
            return @ptrCast(*anyopaque, slice.ptr);
        }
        return null;
    } else return js_malloc(s, size);
}

pub const js_malloc_functions = c.JSMallocFunctions{
    .js_malloc = &js_malloc,
    .js_free = &js_free,
    .js_realloc = &js_realloc,
};
