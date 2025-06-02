const std = @import("std");
const http = std.http;
const json = std.json;
const base64 = std.base64;
const fs = std.fs;

pub const Response = struct {
    pub const Choice = struct {
        message: struct {
            content: []const u8,
        },
    };

    id: ?[]const u8 = null,
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

pub fn chatMulti(
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

    // build request body as a string directly
    var body_buffer = std.ArrayList(u8).init(allocator);
    defer body_buffer.deinit();

    var writer = body_buffer.writer();
    try writer.writeAll("{\"model\":\"");
    try writer.writeAll(model_id);
    try writer.writeAll("\",\"messages\":[{\"role\":\"user\",\"content\":[");

    // add text content
    try writer.writeAll("{\"type\":\"text\",\"text\":\"");
    // escape the prompt properly
    for (prompt) |c| {
        switch (c) {
            '"' => try writer.writeAll("\\\""),
            '\\' => try writer.writeAll("\\\\"),
            '\n' => try writer.writeAll("\\n"),
            '\r' => try writer.writeAll("\\r"),
            '\t' => try writer.writeAll("\\t"),
            else => try writer.writeByte(c),
        }
    }
    try writer.writeAll("\"}");

    if (image_path_or_null) |image_path| {
        // read & base-64 encode.
        var file = try fs.cwd().openFile(image_path, .{});
        defer file.close();

        const raw = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
        defer allocator.free(raw);

        const encoded_size = base64.standard.Encoder.calcSize(raw.len);
        const encoded = try allocator.alloc(u8, encoded_size);
        defer allocator.free(encoded);
        _ = base64.standard.Encoder.encode(encoded, raw);

        const ext_with_dot = std.fs.path.extension(image_path);
        const ext = if (ext_with_dot.len > 0 and ext_with_dot[0] == '.')
            ext_with_dot[1..]
        else
            ext_with_dot;

        try writer.writeAll(",{\"type\":\"image_url\",\"image_url\":{\"url\":\"data:image/");
        try writer.writeAll(ext);
        try writer.writeAll(";base64,");
        try writer.writeAll(encoded);
        try writer.writeAll("\"}}");
    }

    try writer.writeAll("]}]}");

    const payload_bytes = try body_buffer.toOwnedSlice();
    defer allocator.free(payload_bytes);

    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    const auth_header = try std.fmt.allocPrint(allocator, "Bearer {s}", .{api_key});
    defer allocator.free(auth_header);

    var buf: [8192]u8 = undefined;
    var req = try client.open(.POST, uri, .{
        .server_header_buffer = &buf,
        .extra_headers = &.{
            .{ .name = "Authorization", .value = auth_header },
            .{ .name = "Content-Type", .value = "application/json" },
        },
    });
    defer req.deinit();

    req.transfer_encoding = .{ .content_length = payload_bytes.len };
    try req.send();
    try req.writeAll(payload_bytes);
    try req.finish();

    try req.wait();

    const body = try req.reader().readAllAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(body);

    const resp = try json.parseFromSliceLeaky(Response, allocator, body, .{
        .ignore_unknown_fields = true,
    });

    return resp;
}
