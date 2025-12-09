/// 2D point coordinates
pub const Point = struct {
    x: i64,
    y: i64,
};

/// 3D point coordinates
pub const Point3D = struct {
    x: i64,
    y: i64,
    z: i64,
};

/// Line segment between two points
pub const Edge = struct {
    p1: Point,
    p2: Point,
};

/// Calculate squared 3D Euclidean distance between two points
/// Reference: https://en.wikipedia.org/wiki/Euclidean_distance#Higher_dimensions
///
/// Type constraint: T must have x: i64, y: i64, z: i64 fields (Point3DLike)
/// Examples: Point3D, or any struct with those fields like Point3D + id
pub fn euclideanDistance3DSq(comptime T: type, p1: T, p2: T) i64 {
    // Verify that T has the required fields at compile-time
    comptime {
        _ = @as(i64, p1.x);
        _ = @as(i64, p1.y);
        _ = @as(i64, p1.z);
    }

    const dx = p2.x - p1.x;
    const dy = p2.y - p1.y;
    const dz = p2.z - p1.z;
    return dx * dx + dy * dy + dz * dz;
}
