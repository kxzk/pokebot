const std = @import("std");

pub const ColorMagenta: []const u8 = "\x1b[35m";
pub const ColorCyan:   []const u8 = "\x1b[36m";
pub const ColorReset:  []const u8 = "\x1b[0m";

pub fn withTapColor(allocator: *std.mem.Allocator, tag: []const u8) ![]u8 {
    return std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ColorMagenta, tag, ColorReset});
}

pub fn withCmdColor(allocator: *std.mem.Allocator, tag: []const u8) ![]u8 {
    return std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ColorCyan, tag, ColorReset});
}