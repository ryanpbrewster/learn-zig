const std = @import("std");
const sqlite = @cImport(@cInclude("sqlite3.h"));

const DB_NAME = "hello.sqlite";

pub fn main() void {
  var db: ?*sqlite.sqlite3 = undefined;
  _ = sqlite.sqlite3_open(DB_NAME, &db);
  std.debug.print("Opened {s}\n", .{DB_NAME});
  defer {
    std.debug.print("Closing {s}\n", .{DB_NAME});
    _ = sqlite.sqlite3_close(db);
  }

  var err: [*c]u8 = undefined;
  const rc = sqlite.sqlite3_exec(
    db,
    "CREATE TABLE foo (id INTEGER PRIMARY KEY, value TEXT NOT NULL)",
    null,
    null,
    &err,
  );
  std.debug.print("exec: {}\n", .{rc});
  if (rc != 0) {
    std.debug.print("err = {s}\n", .{err});
  }
}
