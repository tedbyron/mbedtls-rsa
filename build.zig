const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const include = [_][]const u8{"libs/mbedtls/include"};

    const lib = b.addStaticLibrary("mbedtls", null);
    lib.setTarget(target);
    lib.setBuildMode(mode);
    if (lib.target.isWindows()) {
        lib.linkSystemLibrary("ws2_32");
    }
    lib.linkLibC();
    for (include) |path| {
        lib.addIncludeDir(path);
    }
    lib.install();

    const exe = b.addExecutable("mbedtls-rsa", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.addIncludeDir("libs/mbedtls/include");
    exe.addIncludeDir("libs/mbedtls/library");
    exe.addCSourceFile("src/main.c", &[_][]const u8{});
    exe.linkLibC();
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the executable");
    run_step.dependOn(&run_cmd.step);
}
