const std = @import("std");

pub fn main() !void {
    // Example: Simulate a screen tap at (x=500, y=500)
    const cmd = "scrcpy --maxsize 1024 --bit-rate 4M --turn-screen-off --show-touches";
    const result = try std.process.Child.spawn(.{
        .allocator = std.heap.page_allocator,
        .argv = &[_][]const u8{ "bash", "-c", cmd },
    });
    std.debug.print("Output: {s}\n", .{result.stdout});
}

