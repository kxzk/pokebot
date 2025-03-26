const std = @import("std");
const andy = @import("andy.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var device = try andy.Andy.init(allocator);
    defer device.deinit();

    try device.tap(.BattleBtn)
    std.time.sleep(10_000_000_000); // 10 seconds (in ns)
    try device.tap(.VersusBtn)
    std.time.sleep(10_000_000_000);
    try device.tap(.RandomMatchBtn)
    std.time.sleep(10_000_000_000);
}
