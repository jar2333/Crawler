const std = @import("std");
const raylib_build = @import("vendor/raylib/src/build.zig");
const ecs_build = @import("vendor/zig-ecs/build.zig");

const addMruby = @import("vendor/mruby-zig/build.zig").addMruby;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // Builds raylib :)
    const raylib = raylib_build.addRaylib(b, target, optimize);

    const exe = b.addExecutable(.{
        .name = "crawler-zig",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Link raylib library
    exe.linkLibrary(raylib);

    // Link ecs library
    ecs_build.linkArtifact(b, exe, target, optimize, .static, "vendor/zig-ecs");

    // MRuby !!!!
    addMruby(exe, b);

    // ---------------------------------
    // Single-header libraries!

    // // stb_connected_component: Finds connected components on 2D grids for testing reachability between two points
    // exe.addCSourceFile("src/cinclude/stb_connected_components.h", &[_][]const u8{ "-std=c99", "-DSTB_CONNECTED_COMPONENTS_IMPLEMENTATION", "-DSTBCC_GRID_COUNT_X_LOG2=10", "-DSTBCC_GRID_COUNT_Y_LOG2=10" });

    // // stb_perlin: Functions for perlin and fractal noise
    // exe.addCSourceFile("src/cinclude/stb_perlin.h", &[_][]const u8{ "-std=c99", "-DSTB_PERLIN_IMPLEMENTATION" });

    // // uastar: Finds paths between two points on a 2D grid
    // exe.addCSourceFile("src/cinclude/uastar.h", &[_][]const u8{ "-std=c99", "-DUASTAR_IMPLEMENTATION" });

    // // stb_image and stb_image_write: Image loader and writers
    // exe.addCSourceFile("src/cinclude/stb_image.h", &[_][]const u8{ "-std=c99", "-DSTB_IMAGE_IMPLEMENTATION" });
    // exe.addCSourceFile("src/cinclude/stb_image_write.h", &[_][]const u8{ "-std=c99", "-DSTB_IMAGE_WRITE_IMPLEMENTATION" });

    // // wfc: Single-file Wave Function Collapse library (overlapping method)
    // exe.addCSourceFile("src/cinclude/wfc.h", &[_][]const u8{ "-std=c99", "-DWFC_USE_STB", "-DWFC_IMPLEMENTATION" });

    // raylib-nuklear - Nuklear for Raylib, use the nuklear immediate-mode graphical user interface in raylib.
    // exe.addCSourceFile("src/cinclude/raylib-nuklear.h", &[_][]const u8{ "-std=c99", "-DRAYLIB_NUKLEAR_IMPLEMENTATION" });

    //----------------------------------

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
