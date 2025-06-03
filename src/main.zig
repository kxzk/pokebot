const std = @import("std");
const andy = @import("andy");
const openai = @import("openai");
const config = @import("config");

fn describe(alloc: std.mem.Allocator, api_key: []const u8, model_id: []const u8, path: []const u8) !void {
    // TODO: update this to be dynamic, will change depending on what we need to know
    const question = "What is in the image?";
    const resp = try openai.chatMulti(alloc, api_key, model_id, question, path);
    if (resp.choices.len > 0) {
        std.debug.print("{s}\n", .{resp.choices[0].message.content});
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const api_key = std.process.getEnvVarOwned(allocator, config.api_key_env) catch return error.MissingApiKey;
    defer allocator.free(api_key);
    const model_id = config.model_id;

    var device = try andy.Andy.init(allocator);
    defer device.deinit();

    std.time.sleep(2_000_000_000);

    // TODO: add startScreenBtn press

    std.time.sleep(2_000_000_000);
    try device.tapAndCapture(.BattleBtn, "cap_battle.png");
    try describe(allocator, api_key, model_id, "cap_battle.png");

    std.time.sleep(5_000_000_000);
    try device.tapAndCapture(.VersusBtn, "cap_versus.png");
    // try describe(allocator, "cap_versus.png");

    std.time.sleep(5_000_000_000);
    try device.tapAndCapture(.RandomMatchBtn, "cap_random.png");
    // try describe(allocator, "cap_random.png");

    std.time.sleep(5_000_000_000);
    try device.tapAndCapture(.StartMatchBtn, "cap_start.png");
    // try describe(allocator, "cap_start.png");
}
