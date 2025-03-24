const std = @import("std");
const print = std.debug.print;
const Child = std.process.Child;

// adb -> /usr/bin/adb
pub fn main() !void {
    const scrcpyArgs = [_][]const u8{ "scrcpy", "--start-app=jp.pokemon.pokemontcgp" };
    const result = try Child.run(.{
        .allocator = std.heap.page_allocator,
        .argv = &scrcpyArgs,
    });
    print("{s}\n", .{result.stdout});
}
