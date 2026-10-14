//! This is used as a replacement for `sed`

const std = @import("std");

pub fn main(init: std.process.Init.Minimal) !void {
    var threaded: std.Io.Threaded = .init_single_threaded;
    const io = threaded.io();

    var arena_allocator: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const arena = arena_allocator.allocator();

    const args = try init.args.toSlice(arena);

    if (args.len != 5) {
        std.debug.print("usage: {s} <input_file> <output_file> <before> <after>\n", .{args[0]});
        std.process.exit(1);
    }

    const input_filename = args[1];
    const output_filename = args[2];
    const before = args[3];
    const after = args[4];

    const input = try std.Io.Dir.cwd().readFileAlloc(io, input_filename, arena, .unlimited);
    const output = try std.mem.replaceOwned(u8, arena, input, before, after);

    try std.Io.Dir.cwd().writeFile(io, .{
        .sub_path = output_filename,
        .data = output,
    });
}
