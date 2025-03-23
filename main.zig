const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const scrcpyArgs = &[_][]const u8{
        "scrcpy",
        "--max-size", "1024",
        "--bit-rate", "4M",
        "--turn-screen-off",
        "--show-touches",
    };

    // --turn-screen-off
    // --stay-awake (prevent device from sleeping)

    var scrcpyChild = std.process.Child.init(scrcpyArgs, allocator);
    scrcpyChild.stdout_behavior = .Inherit;
    scrcpyChild.stderr_behavior = .Inherit;
    try scrcpyChild.spawn();

    std.time.sleep(2 * std.time.ns_per_s);

    // list all apps
    // scrcpy --list-apps

    // start app on launch
    // scrcpy --start-app=org.mozilla.firefox

    _ = try scrcpyChild.wait();
}
