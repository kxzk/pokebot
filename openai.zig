const std = @import("std");
const http = std.http;
const json = std.json;
const base64 = std.base64;
const fs = std.fs;

pub const Response = struct {
    id: ?[]const u8 = null,

    pub const Choice = struct {
        message: struct {
            content: []const u8,
        },
    };

    choices: []Choice,
};

pub fn chat(
    allocator: std.mem.Allocator,
    api_key: []const u8,
    model_id: []const u8,
    prompt: []const u8,
) !Response {
    return try chatInternal(allocator, api_key, model_id, prompt, null);
}

pub fn chat_multi(
    // for image requests
    allocator: std.mem.Allocator,
    api_key: []const u8,
    model_id: []const u8,
    prompt: []const u8,
    image_path: []const u8,
) !Response {
    return try chatInternal(allocator, api_key, model_id, prompt, image_path);
}

fn chatInternal(
    allocator: std.mem.Allocator,
    api_key: []const u8,
    model_id: []const u8,
    prompt: []const u8,
    image_path_or_null: ?[]const u8,
) !Response {

    const uri = try std.Uri.parse("https://api.openai.com/v1/chat/completions");

    var contents = std.ArrayList(json.Value).init(allocator);
    defer contents.deinit();

    try contents.append(json.Value{ .object = &{
        .{ .string = "type", .string_value = "text" },
        .{ .string = "text", .string_value = prompt },
    } });

    if (image_path_or_null) |image_path| {
        // read & base-64 encode.
        var file = try fs.cwd().openFile(image_path, .{});
        defer file.close();

        const raw = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
        defer allocator.free(raw);

        const encoded = base64.standard.Encoder.encode(raw);

        const url_value = try std.fmt.allocPrint(
            allocator,
            "data:image/{s};base64,{s}",
            .{ std.fs.path.extension(image_path), encoded },
        );
        defer allocator.free(url_value);

        try contents.append(json.Value{ .object = &{
            .{ .string = "type", .string_value = "image_url" },
            .{ .string = "image_url", .string_value = url_value },
        } });
    }

    // build the outer `messages` array containing a single user message.
    const message_obj = json.Value{ .object = &{
        .{ .string = "role", .string_value = "user" },
        .{ .string = "content", .array = contents.items },
    } };

    const messages_array = &[_]json.Value{message_obj};

    const payload_json = json.Value{ .object = &{
        .{ .string = "model", .string_value = model_id },
        .{ .string = "messages", .array = messages_array },
    } };

    const payload_bytes = try json.stringifyAlloc(allocator, payload_json, .{});
    defer allocator.free(payload_bytes);

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    var request = try client.request(.POST, uri, .{
        .allocator = allocator,
        .headers = .{
            .authorization = try std.fmt.allocPrint(allocator, "Bearer {s}", .{ api_key }),
            .content_type = "application/json",
        },
    });
    defer request.deinit();

    try request.writeAll(payload_bytes);
    try request.finish();

    try request.wait();

    const body = try request.reader().readAllAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(body);

    const resp = try json.parseFromSliceLeaky(Response, allocator, body, .{
        .ignore_unknown_fields = true,
    });

    return resp;
}
