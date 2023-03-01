const Allocator = @import("std").mem.Allocator;

const c = @cImport({
    @cInclude("quickjs/quickjs.h");
});

const minimumAlignment = 16;

const metadataSize = 16;
const Metadata = struct {
    size: usize,
};
comptime {
    if (@sizeOf(Metadata) > metadataSize)
        @compileError("Metadata must fit in 16 bytes");
}

inline fn getAllocator(s: ?*c.JSMallocState) *const Allocator {
    return @ptrCast(
        *const Allocator,
        @alignCast(@alignOf(Allocator), s.?.@"opaque".?),
    );
}

inline fn getMetadata(ptr: *anyopaque) *Metadata {
    return @intToPtr(*Metadata, @ptrToInt(ptr) - metadataSize);
}

inline fn offsetByMetadata(ptr: *anyopaque) *anyopaque {
    return @intToPtr(*anyopaque, @ptrToInt(ptr) + metadataSize);
}

inline fn getMetadataConst(ptr: *const anyopaque) *const Metadata {
    return @intToPtr(*const Metadata, @ptrToInt(ptr) - metadataSize);
}

inline fn metadataToSizedSlice(metadata: *Metadata) []align(minimumAlignment) u8 {
    return @ptrCast(
        [*]align(minimumAlignment) u8,
        @alignCast(minimumAlignment, metadata),
    )[0 .. metadata.size + metadataSize];
}

pub fn malloc(s: ?*c.JSMallocState, size: usize) callconv(.C) ?*anyopaque {
    if (size == 0) return null;
    const ptr = (getAllocator(s).alignedAlloc(
        u8,
        minimumAlignment,
        size + metadataSize,
    ) catch return null).ptr;
    @ptrCast(*Metadata, ptr).size = size;
    return offsetByMetadata(ptr);
}

pub fn free(s: ?*c.JSMallocState, ptr: ?*anyopaque) callconv(.C) void {
    if (ptr == null) return;
    return getAllocator(s).free(metadataToSizedSlice(getMetadata(ptr.?)));
}

pub fn realloc(
    s: ?*c.JSMallocState,
    ptr: ?*anyopaque,
    size: usize,
) callconv(.C) ?*anyopaque {
    if (ptr == null) return malloc(s, size);
    if (size == 0) {
        free(s, ptr);
        return null;
    }
    const new_ptr = (getAllocator(s).realloc(
        metadataToSizedSlice(getMetadata(ptr.?)),
        size + metadataSize,
    ) catch return null).ptr;
    @ptrCast(*Metadata, new_ptr).size = size;
    return offsetByMetadata(new_ptr);
}

pub fn malloc_usable_size(ptr: ?*const anyopaque) callconv(.C) usize {
    if (ptr == null) return 0;
    return getMetadataConst(ptr.?).size;
}

pub const mf = c.JSMallocFunctions{
    .js_malloc = &malloc,
    .js_free = &free,
    .js_realloc = &realloc,
    .js_malloc_usable_size = &malloc_usable_size,
};
