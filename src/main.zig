const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    const stdin = std.io.getStdIn().reader();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var parser = std.json.Parser.init(allocator, false);
    defer parser.deinit();
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip();
    const operation = args.next().?;

    if (std.mem.eql(u8, operation, "manifest")) {
        const manifest =
            \\ {
            \\ "name": "Name of your package",
            \\ "version": "0.1",
            \\ "description": "A short description that explains the function of your package",
            \\ "transforms": [
            \\     {
            \\         "from": "robber",
            \\         "to": [
            \\             "html",
            \\             "latex"
            \\         ],
            \\         "arguments": []
            \\     }
            \\ ]
            \\ }
        ;
        _ = try stdout.write(manifest);
    }

    if (std.mem.eql(u8, operation, "transform")) {
        const from = args.next().?;
        if (!std.mem.eql(u8, from, "robber")) {
            _ = try stderr.write("Robber package does not support tranformation from anything other than robber\n");
            std.os.exit(0);
        }
        const to = args.next().?;
        if (!(std.mem.eql(u8, to, "html") or std.mem.eql(u8, to, "latex"))) {
            _ = try stderr.write("Robber package only supports html and latex output format\n");
            std.os.exit(0);
        }
        var buf: [10000]u8 = undefined;
        const read = try stdin.readAll(buf[0..]);
        if (parser.parse(buf[0..read])) |tree| {
            const robber = robberTransform(tree.root.Object.get("data").?.String);
            _ = try stdout.write(
                \\[{"name": "raw", "data": 
            );
            try std.json.encodeJsonString(robber, .{}, stdout);
            _ = try stdout.write(
                \\}]
            );
        } else |_| {
            _ = try stderr.write("Input is too large\n");
            std.os.exit(0);
        }
    }
}

pub fn robberTransform(input: []const u8) []const u8 {
    const consCount = consonantCount(input);
    const outputSize = consCount * 2 + input.len;
    var output: [30000]u8 = undefined;
    var i: usize = 0;
    for (input) |c| {
        if (isConsonant(c)) {
            output[i] = c;
            i += 1;
            output[i] = 'o';
            i += 1;
            output[i] = c;
            i += 1;
        } else {
            output[i] = c;
            i += 1;
        }
    }
    const outputSlice = output[0..outputSize];
    return outputSlice;
}

pub fn consonantCount(input: []const u8) usize {
    var count: usize = 0;
    for (input) |c| {
        if (isConsonant(c)) {
            count += 1;
        }
    }
    return count;
}

pub fn isConsonant(c: u8) bool {
    if ((c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z')) {
        switch (c) {
            'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U' => return false,
            else => return true,
        }
    }
    return false;
}
