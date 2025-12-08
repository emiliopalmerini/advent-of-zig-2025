const std = @import("std");

/// Disjoint Set Union (Union-Find) data structure
/// Implementation based on: https://en.wikipedia.org/wiki/Disjoint-set_data_structure
pub fn DSU(comptime T: type) type {
    return struct {
        parent: std.ArrayList(T),
        size: std.ArrayList(T),

        const Self = @This();

        /// Initialize a new DSU with n elements, each in its own set
        pub fn init(allocator: std.mem.Allocator, n: usize) !Self {
            var parent = try std.ArrayList(T).initCapacity(allocator, n);
            var size = try std.ArrayList(T).initCapacity(allocator, n);

            for (0..n) |i| {
                try parent.append(allocator, @intCast(i));
                try size.append(allocator, 1);
            }

            return Self{
                .parent = parent,
                .size = size,
            };
        }

        /// Free allocated memory
        pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            self.parent.deinit(allocator);
            self.size.deinit(allocator);
        }

        /// Find the representative (root) of the set containing x.
        /// Uses path compression to flatten the tree structure for faster future lookups.
        pub fn find(self: *Self, x: T) T {
            const x_val: usize = @intCast(x);
            const parent_val: usize = @intCast(self.parent.items[x_val]);

            if (parent_val != x_val) {
                const root = self.find(@intCast(parent_val));
                self.parent.items[x_val] = root;
                return root;
            }
            return x;
        }

        /// Unite (merge) the sets containing x and y.
        /// Uses union by size: the smaller tree is attached under the larger tree.
        pub fn unite(self: *Self, x: T, y: T) bool {
            const root_x = self.find(x);
            const root_y = self.find(y);

            if (root_x == root_y) {
                return false;
            }

            const root_x_val: usize = @intCast(root_x);
            const root_y_val: usize = @intCast(root_y);

            // Union by size: attach smaller tree under larger tree
            if (self.size.items[root_x_val] < self.size.items[root_y_val]) {
                self.parent.items[root_x_val] = root_y;
                self.size.items[root_y_val] += self.size.items[root_x_val];
            } else {
                self.parent.items[root_y_val] = root_x;
                self.size.items[root_x_val] += self.size.items[root_y_val];
            }

            return true;
        }

        /// Get the size of the set containing x
        pub fn getSize(self: *Self, x: T) T {
            const root = self.find(x);
            const root_val: usize = @intCast(root);
            return self.size.items[root_val];
        }

        /// Collect all unique set representatives and their sizes
        /// Returns an ArrayList of sizes, one entry per disjoint set
        pub fn getRootSizes(self: *Self, allocator: std.mem.Allocator) !std.ArrayList(T) {
            var roots = try std.ArrayList(T).initCapacity(allocator, 100);
            var seen = std.AutoHashMap(T, void).init(allocator);
            defer seen.deinit();

            for (0..self.parent.items.len) |i| {
                const root = self.find(@intCast(i));
                if (!seen.contains(root)) {
                    try seen.put(root, {});
                    try roots.append(allocator, self.size.items[@intCast(root)]);
                }
            }

            return roots;
        }
    };
}
