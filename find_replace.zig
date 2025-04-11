//! This is used as a replacement for `sed`

const std = @import("std");

pub fn main() !void {
    var general_purpose_allocator: std.heap.GeneralPurposeAllocator(.{}) = .{};
    defer _ = general_purpose_allocator.deinit();
    const gpa = general_purpose_allocator.allocator();

    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    const stderr = std.io.getStdErr().writer();

    if (args.len != 5) {
        try stderr.print("usage: {s} <input_file> <output_file> <before> <after>\n", .{args[0]});
        std.process.exit(1);
    }

    const input_filename = args[1];
    const output_filename = args[2];
    const before = args[3];
    const after = args[4];

    const input = try std.fs.cwd().readFileAlloc(gpa, input_filename, std.math.maxInt(u32));
    defer gpa.free(input);

    const output = try std.mem.replaceOwned(u8, gpa, input, before, after);
    defer gpa.free(output);

    try std.fs.cwd().writeFile(.{
        .sub_path = output_filename,
        .data = output,
    });
}
