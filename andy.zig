const std = @import("std");
const ui = @import("ui.zig");

pub const Andy = struct {
    allocator: std.mem.Allocator,
    scrcpy_process: std.process.Child,

    pub fn init(allocator: std.mem.Allocator) !Andy {
        const scrcpy_path = "/home/feyd/scrcpy-linux-x86_64-v3.1/scrcpy";

        var child = std.process.Child.init(&[_][]const u8{
            scrcpy_path,
            "--start-app=jp.pokemon.pokemontcgp",
            // --always-on-top
            // --no-audio
            // --turn-screen-off
            // --stay-awake
            // --max-size= limit resolution while keeping aspect ratio
            // --bit-rate= lower for bandwidth, higher for quality
        }, allocator);

        child.stdin_behavior = .Pipe;
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;

        try child.spawn();

        return Andy{
            .allocator = allocator,
            .scrcpy_process = child,
        };
    }

    pub fn deinit(self: *Andy) void {
        _ = self.scrcpy_process.kill() catch {};
    }

    pub fn tap(self: Andy, element: ui.UI) !void {
        const xy = element.coords();
        try self.use_tap(xy[0], xy[1]);
    }

    fn use_tap(self: Andy, x: u16, y: u16) !void {
        const x_str = try std.fmt.allocPrint(self.allocator, "{}", .{x});
        defer self.allocator.free(x_str);
        const y_str = try std.fmt.allocPrint(self.allocator, "{}", .{y});
        defer self.allocator.free(y_str);

        try self.exec_adb(&.{
            "shell", "input", "tap", x_str, y_str,
        });
    }

    pub fn swipe(self: Andy, x1: u16, y1: u16, x2: u16, y2: u16) !void {
        const x1_str = try std.fmt.allocPrint(self.allocator, "{}", .{x1});
        defer self.allocator.free(x1_str);
        const y1_str = try std.fmt.allocPrint(self.allocator, "{}", .{y1});
        defer self.allocator.free(y1_str);
        const x2_str = try std.fmt.allocPrint(self.allocator, "{}", .{x2});
        defer self.allocator.free(x2_str);
        const y2_str = try std.fmt.allocPrint(self.allocator, "{}", .{y2});
        defer self.allocator.free(y2_str);

        try self.exec_adb(&.{
            "shell", "input", "swipe", x1_str, y1_str, x2_str, y2_str,
        });
    }

    fn exec_adb(self: Andy, args: []const []const u8) !void {
        var argv = std.ArrayList([]const u8).init(self.allocator);
        defer argv.deinit();

        const adb_path = [_][]const u8{"/usr/bin/adb"};
        try argv.appendSlice(&adb_path);

        for (args) |arg| {
            try argv.append(arg);
        }

        std.debug.print("[cmd]: ", .{});
        for (argv.items) |arg| {
            std.debug.print("{s} ", .{arg});
        }
        std.debug.print("\n", .{});

        var proc = std.process.Child.init(argv.items, self.allocator);

        try proc.spawn();

        _ = try proc.wait();
    }
};
