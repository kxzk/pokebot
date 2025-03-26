pub const UI = enum {
    BattleBtn,
    VersusBtn,
    RandomMatchBtn,

    // only for: 1080 x 2340
    pub fn coords(element: UI) [2]u16 {
        return swtich (element) {
            .BattleBtn => .{719, 2288},
            .VersusBtn => .{260, 1912},
            .RandomMatchBtn => .{739, 1947},
        }
    };
}
