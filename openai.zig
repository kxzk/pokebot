const std = @import("std");
const http = std.http;
const json = std.json;
const base64 = std.base64;
const fs = std.fs;

pub const OpenAIRequest = struct {
    model_id: []const u8,
    prompt: []const u8,
    image_locations: ?[][]const u8 = null,
    api_key: []const u8,

    const Content = struct {
        type: []const u8,
        text: ?[]const u8 = null,
        image_url: ?[]const u8 = null,
    };

    const Input = struct {
        role: []const u8,
        content: []Content,
    };

    const Payload = struct {
        model: []const u8,
        input: []Input,
    };

    const Response = struct {
        id: []const u8,
        object: []const u8,
        created: u64,
        // Add other response fields as needed
    };

    pub fn sendRequest(self: *const OpenAIRequest, allocator: std.mem.Allocator) !Response {
        var client = http.Client{ .allocator = allocator };
        defer client.deinit();

        const uri = try std.Uri.parse("https://api.openai.com/v1/chat/responses");
        
        var contents = std.ArrayList(Content).init(allocator);
        defer contents.deinit();

        try contents.append(.{
            .type = "text",
            .text = self.prompt,
        });

        if (self.image_locations) |image_paths| {
            for (image_paths) |path| {
                var file = try fs.cwd().openFile(path, .{});
                defer file.close();

                const image_data = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
                defer allocator.free(image_data);

                const encoded = base64.standard.Encoder.encode(image_data);
                const image_url = try std.fmt.allocPrint(
                    allocator,
                    "data:image/{s};base64,{s}",
                    .{ std.fs.path.extension(path), encoded }
                );
                defer allocator.free(image_url);

                try contents.append(.{
                    .type = "image_url",
                    .image_url = image_url,
                });
            }
        }

        const input = Input{
            .role = "user",
            .content = contents.items,
        };

        const payload = Payload{
            .model = self.model_id,
            .input = &.{input},
        };

        var request = try client.request(.POST, uri, .{
            .allocator = allocator,
            .headers = .{
                .authorization = try std.fmt.allocPrint(allocator, "Bearer {s}", .{self.api_key}),
                .content_type = "application/json",
            },
        });
        defer request.deinit();

        try request.send(.{.allocator = allocator}, payload);

        try request.wait();
        const response_body = try request.reader().readAllAlloc(allocator, std.math.maxInt(usize));
        defer allocator.free(response_body);

        return try json.parseFromSliceLeaky(
            Response,
            allocator,
            response_body,
            .{ .ignore_unknown_fields = true }
        );
    }
};
