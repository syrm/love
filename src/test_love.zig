const heap = @import("std").heap;
const love = @import("love.zig");
const testing = @import("std").testing;
const ArrayList = @import("std").ArrayList;

const ExpectedLoveResult = struct {
    firstPerson: love.Person,
    secondPerson: love.Person,
    result: u8
};

test "love calculator" {
    var arena = heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var expectedResults = ArrayList(ExpectedLoveResult).init(allocator);
    try expectedResults.append(ExpectedLoveResult{
        .firstPerson = love.Person.init("brad", "pitt"),
        .secondPerson = love.Person.init("angelina", "jolie"),
        .result = 74,
    });

    try expectedResults.append(ExpectedLoveResult{
        .firstPerson = love.Person.init("john", "fitzgerald"),
        .secondPerson = love.Person.init("jackie", "kennedy"),
        .result = 57,
    });

    for (expectedResults.items) |er| {
        const result = try love.loveCalculator(allocator,er.firstPerson, er.secondPerson);
        try testing.expectEqual(@as(u8, er.result), result);
    }
}
