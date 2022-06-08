const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("mbedtls", null);
    lib.setTarget(target);
    lib.setBuildMode(mode);
    if (lib.target.isWindows()) {
        lib.linkSystemLibrary("ws2_32");
    }
    lib.addIncludeDir("libs/mbedtls/include");
    lib.addIncludeDir("libs/mbedtls/library");
    lib.addCSourceFile("libs/mbedtls/library/rsa.c", &[_][]const u8{});
    lib.addCSourceFile("libs/mbedtls/library/sha256.c", &[_][]const u8{});
    lib.linkLibC();
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
