const Allocator = @import("std").mem.Allocator;
const ArrayList = @import("std").ArrayList;
const StringHashMap = @import("std").StringHashMap;

pub const OrderedHashMap = struct {
    keys: ArrayList([]const u8),
    map: StringHashMap(u8),
    allocator: Allocator,

    pub fn init(allocator: Allocator) OrderedHashMap {
        return OrderedHashMap {
            .keys = ArrayList([]const u8).init(allocator),
            .map = StringHashMap(u8).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: OrderedHashMap) void {
        self.keys.deinit();
        self.map.deinit();
    }

    pub fn put(self: *OrderedHashMap, key: []const u8, value: u8) !void {
        if (self.map.get(key) == null) {
            try self.keys.append(key);
        }

        try self.map.put(key, value);
    }

    pub fn get(self: OrderedHashMap, key: []const u8) ?u8 {
        return self.map.get(key);
    }

    pub fn values(self: *OrderedHashMap) !ArrayList(u8) {
        var values_list = ArrayList(u8).init(self.allocator);

        for (self.keys.items) |key| {
            if (self.get(key)) |item| {
                try values_list.append(item);
            }
        }

        return values_list;
    }
};
