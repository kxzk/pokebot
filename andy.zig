const std = @import("std");
const ui = @import("ui.zig");

pub const Andy = struct {
    allocator: std.mem.Allocator,
    scrcpy_process: std.process.Child,

    pub fn init(allocator: std.mem.Allocator) !Andy {
        const scrcpy_path = "/home/feyd/scrcpy-linux-x86_64-v3.1/scrcpy";

        var child = std.process.Child.init(
            &[_][]const u8 {
                scrcpy_path,
                "--start-app=jp.pokemon.pokemontcgp",
                // --always-on-top
                // --no-audio
                // --turn-screen-off
                // --stay-awake
                // --max-size= limit resolution while keeping aspect ratio
                // --bit-rate= lower for bandwidth, higher for quality
            },
            allocator
        );

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
        try self.exec_adb(&[_][]const u8 {
            "shell", "input", "tap",
            try std.fmt.allocPrint(self.allocator, "{}", .{x}),
            try std.fmt.allocPrint(self.allocator, "{}", .{y}),
        });
    }

    pub fn swipe(self: Andy, x1: u16, y1: u16, x2: u16, y2: u16) !void {
        try self.exec_adb(&[_][]const u8 {
            "shell", "input", "swipe",
            try std.fmt.allocPrint(self.allocator, "{}", .{x1}),
            try std.fmt.allocPrint(self.allocator, "{}", .{y1}),
            try std.fmt.allocPrint(self.allocator, "{}", .{x2}),
            try std.fmt.allocPrint(self.allocator, "{}", .{y2}),
        });
    }

    fn exec_adb(self: Andy, args: []const []const u8) !void {
        // TODO: fix this - there is no spacing between arguments
        const adb_path = "/usr/bin/adb";

        var argv = std.ArrayList([]const u8).init(self.allocator);
        defer argv.deinit();

        try argv.append(adb_path);
        try argv.appendSlice(args);

        for (argv.items) |arg| {
            std.debug.print("{s}", .{arg});
        }

        const result = try std.process.Child.run(.{
            .allocator = self.allocator,
            .argv = argv.items,
        });

        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }

        if (result.term != .Exited or result.term.Exited != 0) {
            return error.AdbCommandFailed;
        }
    }

};
