const std = @import("std");
const colors = @import("colors");

test "withTapColor wraps tag with magenta and reset" {
    const allocator = std.testing.allocator;
    const tag = "[tap]";
    const result = try colors.withTapColor(allocator, tag);
    defer allocator.free(result);

    const expected = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{colors.ColorMagenta, tag, colors.ColorReset});
    defer allocator.free(expected);

    try std.testing.expectEqualStrings(expected, result);
}

test "withCmdColor wraps tag with cyan and reset" {
    const allocator = std.testing.allocator;
    const tag = "[cmd]";
    const result = try colors.withCmdColor(allocator, tag);
    defer allocator.free(result);

    const expected = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{colors.ColorCyan, tag, colors.ColorReset});
    defer allocator.free(expected);

    try std.testing.expectEqualStrings(expected, result);
}