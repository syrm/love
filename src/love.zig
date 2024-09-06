const fmt = @import("std").fmt;
const grapheme = @import("grapheme");
const unicode = @import("std").unicode;
const Allocator = @import("std").mem.Allocator;
const ArrayList = @import("std").ArrayList;

const OrderedHashMap = @import("ordered_hashmap.zig").OrderedHashMap;

pub const Person = struct {
    firstname: []const u8,
    lastname: []const u8,

    pub fn init(firstname: []const u8, lastname: []const u8) Person {
        return Person{
            .firstname = firstname,
            .lastname = lastname,
        };
    }

    fn len(self: Person) !u16 {
        return try unicode.utf8CountCodepoints(self.firstname) + try unicode.utf8CountCodepoints(self.lastname.len);
    }
};

pub fn loveCalculator(allocator: Allocator, firstPerson: Person, secondPerson: Person) !u8 {
    const names_to_compute = try fmt.allocPrint(allocator, "{s}{s}{s}{s}", .{
        firstPerson.firstname,
        firstPerson.lastname,
        secondPerson.firstname,
        secondPerson.lastname,
    });

    var chars_freq = try characterFrequency(allocator, names_to_compute);
    var computed_freqs = try chars_freq.values();

    while (computed_freqs.items.len > 2) {
        var new_computed_freqs = ArrayList(u8).init(allocator);

        for (0..(computed_freqs.items.len-1)) |index | {
            var computed_freq = computed_freqs.items[index] + computed_freqs.items[index + 1];

            if (computed_freq > 9) {
                const left_part = @divTrunc(computed_freq, 10);
                const right_part = computed_freq - left_part * 10;

                computed_freq = left_part + right_part;
            }

            try new_computed_freqs.append(computed_freq);
        }

        computed_freqs = new_computed_freqs;
    }

    return computed_freqs.items[0] * 10 + computed_freqs.items[1];
}

fn characterFrequency(allocator: Allocator, text: []const u8) !OrderedHashMap {
    var rune_freq = OrderedHashMap.init(allocator);

    const gd = try grapheme.GraphemeData.init(allocator);
    defer gd.deinit();

    var iter = grapheme.Iterator.init(text, &gd);
    while (iter.next()) |g| {
        const grapheme_text = g.bytes(text);
        const freq = rune_freq.get(grapheme_text) orelse 0;

        try rune_freq.put(grapheme_text, freq + 1);
    }

    return rune_freq;
}
