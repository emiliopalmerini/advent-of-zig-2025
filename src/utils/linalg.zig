const std = @import("std");

/// Solve a system of linear equations using Gaussian elimination with back substitution.
/// Expects an augmented matrix [A | b] where:
/// - matrix[i][j] for j < num_cols-1 represents coefficient matrix A
/// - matrix[i][num_cols-1] represents the target vector b
///
/// Returns the solution vector. If no valid solution exists (inconsistent system,
/// non-integer solutions, or negative values), returns a zero-filled vector.
///
/// Uses i128 arithmetic to prevent overflow during elimination and normalizes rows
/// by their GCD to keep coefficients small and manageable.
///
/// Note: This modifies the input matrix during elimination.
pub fn gaussianElimination(
    allocator: std.mem.Allocator,
    matrix: [][]i64,
    num_vars: usize,
) ![]i64 {
    const num_equations = matrix.len;
    var solution = try allocator.alloc(i64, num_vars);
    @memset(solution, 0);

    if (num_equations == 0) {
        return solution;
    }

    const num_cols = matrix[0].len;

    // Forward elimination: reduce matrix to row echelon form
    var pivot_col: usize = 0;
    var row: usize = 0;
    while (row < num_equations and pivot_col < num_vars) {
        // Find the row with the largest absolute value in the pivot column (partial pivoting)
        var pivot_row = row;
        for (row + 1..num_equations) |r| {
            if (@abs(matrix[r][pivot_col]) > @abs(matrix[pivot_row][pivot_col])) {
                pivot_row = r;
            }
        }

        // If pivot is zero, move to next column
        if (matrix[pivot_row][pivot_col] == 0) {
            pivot_col += 1;
            continue;
        }

        // Swap rows to move pivot to current row
        std.mem.swap([]i64, &matrix[row], &matrix[pivot_row]);

        // Eliminate the pivot column in all rows below current row
        for (row + 1..num_equations) |r| {
            if (matrix[r][pivot_col] != 0) {
                const factor = matrix[r][pivot_col];
                const pivot_val = matrix[row][pivot_col];

                // Use i128 to prevent overflow during cross-multiplication
                // R_r = R_r * pivot - R_row * factor
                for (0..num_cols) |col| {
                    const a = @as(i128, matrix[r][col]) * @as(i128, pivot_val);
                    const b = @as(i128, matrix[row][col]) * @as(i128, factor);
                    matrix[r][col] = @intCast(a - b);
                }

                // Normalize row by GCD to keep numbers small and prevent overflow
                normalizeRow(matrix[r]);
            }
        }

        row += 1;
        pivot_col += 1;
    }

    // Back substitution: solve for each variable starting from bottom row
    if (row > 0) {
        var curr_row = row;
        while (curr_row > 0) : (curr_row -= 1) {
            const r_idx = curr_row - 1;

            // Find the first non-zero coefficient in this row (the pivot)
            var col_idx: usize = num_vars;
            for (0..num_vars) |col| {
                if (matrix[r_idx][col] != 0) {
                    col_idx = col;
                    break;
                }
            }

            // If no pivot exists, check if equation is consistent
            if (col_idx == num_vars) {
                if (matrix[r_idx][num_cols - 1] != 0) {
                    @memset(solution, 0);
                    return solution; // Inconsistent: 0 = non-zero
                }
            } else {
                // Solve for variable at col_idx
                var rhs = matrix[r_idx][num_cols - 1];
                for (0..num_vars) |col| {
                    if (col != col_idx) {
                        rhs -= matrix[r_idx][col] * solution[col];
                    }
                }

                const coeff = matrix[r_idx][col_idx];

                // Check if solution is an integer
                if (@rem(rhs, coeff) != 0) {
                    @memset(solution, 0);
                    return solution; // Non-integer solution
                }

                const val = @divExact(rhs, coeff);

                // Only non-negative solutions are valid
                if (val < 0) {
                    @memset(solution, 0);
                    return solution;
                }

                solution[col_idx] = val;
            }
        }
    }

    return solution;
}

/// Divide a row by the GCD of all its elements to keep coefficients manageable
fn normalizeRow(row: []i64) void {
    if (row.len == 0) return;

    var common: u64 = 0;

    // Calculate GCD of the whole row
    for (row) |val| {
        if (val != 0) {
            if (common == 0) {
                common = @abs(val);
            } else {
                common = std.math.gcd(common, @abs(val));
            }
        }
    }

    if (common > 1) {
        for (row) |*val| {
            val.* = @divExact(val.*, @as(i64, @intCast(common)));
        }
    }
}
