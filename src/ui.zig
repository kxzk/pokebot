pub const UI = enum {
    // TODO: add generic tap
    StartScreenTap,
    BattleBtn,
    VersusBtn,
    RandomMatchBtn,
    StartMatchBtn,

    // only for: 1080 x 2340
    pub fn coords(element: UI) [2]u16 {
        return switch (element) {
            .StartScreenTap => .{ 543, 2067 },
            .BattleBtn => .{ 719, 2288 },
            .VersusBtn => .{ 260, 1912 },
            .RandomMatchBtn => .{ 739, 1947 },
            .StartMatchBtn => .{ 540, 1916 },
        };
    }
};
