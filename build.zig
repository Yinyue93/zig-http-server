const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard CLI options (-Dtarget, -Doptimize)
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ---- 1.  define a root module ------------------------------------------
    const server_mod = b.createModule(.{
        .root_source_file = b.path("server.zig"),
        .target   = target,
        .optimize = optimize,
    });

    // ---- 2.  build the executable ------------------------------------------
    const exe = b.addExecutable(.{
        .name        = "server",
        .root_module = server_mod,
    });
    exe.linkSystemLibrary("ws2_32");       // Winsock 2 for Windows networking

    // ---- 3.  install on `zig build` ----------------------------------------
    b.installArtifact(exe);

    // ---- 4.  expose `zig build run` ----------------------------------------
    const run_cmd = b.addRunArtifact(exe);
    // optional: pass command-line args → run_cmd.addArg("8080");
    b.step("run", "Build and launch the HTTP server")
        .dependOn(&run_cmd.step);
}
