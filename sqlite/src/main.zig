const std = @import("std");
const sqlite = @cImport(@cInclude("sqlite3.h"));

const DB_NAME = "hello.sqlite";

pub fn main() !void {
    var db = try Database.init(DB_NAME);
    std.debug.print("Opened {s}\n", .{DB_NAME});
    defer {
        std.debug.print("Closing {s}\n", .{DB_NAME});
        db.deinit() catch {};
    }

    try db.exec("CREATE TABLE IF NOT EXISTS foo (id INTEGER PRIMARY KEY, value TEXT NOT NULL)");
    std.debug.print("Created table 'foo'\n", .{});
    try db.exec("INSERT OR IGNORE INTO foo (id, value) VALUES (1, 'hello')");
    std.debug.print("Inserted record (1, 'hello') into 'foo'\n", .{});
}

const Database = struct {
    const Self = @This();
    db: *sqlite.sqlite3,

    fn init(name: [*c]const u8) !Database {
        var db: ?*sqlite.sqlite3 = undefined;
        const rc = sqlite.sqlite3_open(name, &db);
        if (rc != 0) {
            return SqliteError.Unknown;
        }
        return Database{ .db = db.? };
    }
    fn deinit(self: *Self) !void {
        const rc = sqlite.sqlite3_close(self.db);
        if (rc != 0) {
            return SqliteError.Unknown;
        }
    }

    fn exec(self: *Self, sql: [*c]const u8) !void {
        var err: [*c]u8 = undefined;
        const rc = sqlite.sqlite3_exec(
            self.db,
            sql,
            null,
            null,
            &err,
        );
        if (rc != 0) {
            std.log.warn("sqlite3_exec error: {s}\n", .{err});
            return SqliteError.Unknown;
        }
    }
};

const SqliteError = error{
    Unknown,
};
