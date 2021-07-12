const print = @import("std").debug.print;
const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("main.exe", "src/main.zig");
    exe.setTarget(.{
      .abi = .musl,
    });
    exe.setBuildMode(mode);
    exe.linkLibC();
    exe.addIncludeDir("lib/sqlite");
    exe.addCSourceFile("lib/sqlite/sqlite3.c", &[_][]const u8{
        "-Wall",
        "-Wextra",
        "-Werror",
    });
    exe.install();

    print("Installed to zig-cache/bin/main.exe\n", .{});

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

