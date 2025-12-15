const std = @import("std");

pub fn main() !void {
    // 标准输出
    const stdout = std.io.getStdOut().writer();

    // 使用 GPA（通用目的分配器）
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 你的代码
    try stdout.print("Hello, Zig!\n", .{});

    _ = allocator; // 如果不使用可以删除这行
}

test "basic test" {
    const expect = @import("std").testing.expect;
    try expect(true);
}
