const std = @import("std");
const mruby = @import("mruby");

pub fn main() anyerror!void {
    // Opening a state
    var mrb = try mruby.open();
    defer mrb.close();

    // Loading a program from a string
    _ = mrb.load_string("puts 'hello from ruby!'");
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
