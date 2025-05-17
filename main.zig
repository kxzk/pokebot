const std = @import("std");
const andy = @import("andy.zig");
const openai = @import("openai.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const api_key = std.os.getenv("OAI_POKEBOT") orelse return error.MissingApiKey;
    const model_id = "gpt-4o";

    var device = try andy.Andy.init(allocator);
    defer device.deinit();

    // helper to send screenshot to OpenAI and print description
    fn describe(alloc: std.mem.Allocator, path: []const u8) !void {
        var resp = try openai.chat_multi(alloc, api_key, model_id,
            "What is in the image?", path);
        if (resp.choices.len > 0) {
            std.debug.print("{s}\n", .{resp.choices[0].message.content});
        }
    }

    std.time.sleep(2_000_000_000);
    try device.tapAndCapture(.BattleBtn, "cap_battle.png");
    try describe(allocator, "cap_battle.png");

    std.time.sleep(5_000_000_000);
    try device.tapAndCapture(.VersusBtn, "cap_versus.png");
    try describe(allocator, "cap_versus.png");

    std.time.sleep(5_000_000_000);
    try device.tapAndCapture(.RandomMatchBtn, "cap_random.png");
    try describe(allocator, "cap_random.png");

    std.time.sleep(5_000_000_000);
    try device.tapAndCapture(.StartMatchBtn, "cap_start.png");
    try describe(allocator, "cap_start.png");
}
