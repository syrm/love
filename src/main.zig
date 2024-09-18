const io = @import("std").io;
const mem = @import("std").mem;
const heap = @import("std").heap;
const os = @import("std").os;
const process = @import("std").process;
const ArrayList = @import("std").ArrayList;

const love = @import("love.zig");

pub fn main() !void {
    var arena = heap.ArenaAllocator.init(heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    var firstname1: ?[]u8 = null;
    var lastname1: ?[]u8 = null;
    var firstname2: ?[]u8 = null;
    var lastname2: ?[]u8 = null;

    var index: usize = 0;
    while(index < args.len) : (index += 1) {
        if (args.len <= index+1) {
            break;
        }

        if (mem.eql(u8, args[index], "--firstname1")) {
            index += 1;
            firstname1 = args[index];
        } else if (mem.eql(u8, args[index], "--lastname1")) {
            index += 1;
            lastname1 = args[index];
        } else if (mem.eql(u8, args[index], "--firstname2")) {
            index += 1;
            firstname2 = args[index];
        } else if (mem.eql(u8, args[index], "--lastname2")) {
            index += 1;
            lastname2 = args[index];
        }
    }

    const stdout = io.getStdOut().writer();

    if (firstname1 == null or lastname1 == null or firstname2 == null or lastname2 == null) {
        try stdout.print("Missing names\n", .{});
        return;
    }

    const firstPerson = love.Person.init(firstname1.?, lastname1.?);
    const secondPerson = love.Person.init(firstname2.?, lastname2.?);

    const result = try love.loveCalculator(allocator, firstPerson, secondPerson);

    try stdout.print("Love result: {}%\n", .{result});
}
