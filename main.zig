const std = @import("std");
const andy = @import("andy.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var device = try andy.Andy.init(allocator);
    defer device.deinit();

    try device.tap(719, 2288);
    std.time.sleep(1_000_000_000);
    try device.tap(260, 1912);
    std.time.sleep(1_000_000_000);
    try device.tap(739, 1947);
    std.time.sleep(1_000_000_000);
}
