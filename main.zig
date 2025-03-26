const std = @import("std");
const andy = @import("andy.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var device = try andy.Andy.init(allocator);
    defer device.deinit();

    // TODO: if start screen, recognize, and then tap
    // maybe move tap to a generic tap

    // TODO: maybe add sleep to tap
    std.time.sleep(2_000_000_000);
    try device.tap(.BattleBtn);
    std.time.sleep(5_000_000_000); // 5 seconds (in ns)
    try device.tap(.VersusBtn);
    std.time.sleep(5_000_000_000);
    try device.tap(.RandomMatchBtn);
    std.time.sleep(5_000_000_000);
    try device.tap(.StartMatchBtn);
}
