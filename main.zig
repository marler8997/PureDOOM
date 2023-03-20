const std = @import("std");
const c = @cImport({
    // Cannot use DOOM_IMPLEMENTATION here because zig doesn't compile the C code, just interprets headers
    //@cDefine("DOOM_IMPLMENTATION", "1");
    @cInclude("PureDOOM.h");
});
const cstd = @import("cstd");

pub fn main() void {
    //c.doom_set_getenv(getenv);
    c.doom_set_print(print);
    c.doom_set_malloc(malloc, free);
    c.doom_set_file_io(
        open,
        null,//close,
        null,//read,
        null,//write,
        null,//seek,
        null,//tell,
        null,//eof,
    );

    c.doom_init(
        @intCast(c_int, std.os.argv.len),
        @ptrCast([*c][*c]u8, std.os.argv.ptr),
        0,
    );
    while (true) {
        c.doom_update();
    }
}

fn print(str: [*c]const u8) callconv(.C) void {
    std.io.getStdOut().writer().writeAll(std.mem.span(str)) catch |err|
        std.debug.panic("write to stdout failed with error {s}", .{@errorName(err)});
}
fn malloc(size: c_int) callconv(.C) ?*anyopaque {
    return cstd.malloc(std.math.cast(usize, size) orelse return null);
}
fn free(ptr: ?*anyopaque) callconv(.C) void {
    cstd.free(@alignCast(16, @ptrCast(?[*]u8, ptr)));
}
fn open(filename: [*c]const u8, mode: [*c]const u8) callconv(.C) ?*anyopaque {
    return cstd.fopen(filename, mode);
}


//typedef void*(*doom_open_fn)(const char* filename, const char* mode);
//typedef void(*doom_close_fn)(void* handle);
//typedef int(*doom_read_fn)(void* handle, void *buf, int count);
//typedef int(*doom_write_fn)(void* handle, const void *buf, int count);
//typedef int(*doom_seek_fn)(void* handle, int offset, doom_seek_t origin);
//typedef int(*doom_tell_fn)(void* handle);
//typedef int(*doom_eof_fn)(void* handle);
//typedef void(*doom_gettime_fn)(int* sec, int* usec);
//typedef void(*doom_exit_fn)(int code);
//typedef char*(*doom_getenv_fn)(const char* var);
//


// copied from ziglibc (for now)
