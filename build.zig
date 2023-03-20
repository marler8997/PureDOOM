const std = @import("std");
const GitRepoStep = @import("GitRepoStep.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ziglibc_repo = GitRepoStep.create(b, .{
        .url = "https://github.com/marler8997/ziglibc",
        .sha = "f9bfe4e13a75d9d02fdb7ca9c2b6f20137d6ccb1",
        .fetch_enabled = true,
    });
    const trace_enabled = b.option(bool, "trace", "enable libc tracing") orelse false;
    const trace_options = b.addOptions();
    trace_options.addOption(bool, "enabled", trace_enabled);
    const trace_options_module = trace_options.createModule();

    const cstd_module = b.addModule("cstd", .{
        .source_file = .{ .path = b.pathJoin(&.{ziglibc_repo.path, "src", "cstd.zig"}) },
        .dependencies = &.{
            .{ .name = "trace_options", .module = trace_options_module },
        },
    });

    const exe = b.addExecutable(.{
        .name = "PureDOOM",
        .root_source_file = .{ .path = "main.zig" },
        .target = target,
        .optimize = optimize,
    });
    //exe.addCSourceFiles(&.{ "PureDOOM.c" }, &.{
    //"-DDOOM_IMPLMENTATION=1",
    //"-DDOOM_IMPLEMENT_PRINT=1",
    //});
    exe.addCSourceFiles(doom_src_files, &[_][]const u8 { });
    exe.addIncludePath(".");

    exe.step.dependOn(&ziglibc_repo.step);
    exe.addIncludePath(b.pathJoin(&.{ziglibc_repo.path, "inc/libc"}));
    exe.addModule("cstd", cstd_module);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
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
}

const doom_src_files = &[_][]const u8 {
    "src/DOOM/am_map.c",
    "src/DOOM/d_items.c",
    "src/DOOM/d_main.c",
    "src/DOOM/d_net.c",
    "src/DOOM/DOOM.c",
    "src/DOOM/doomdef.c",
    "src/DOOM/doomstat.c",
    "src/DOOM/dstrings.c",
    "src/DOOM/f_finale.c",
    "src/DOOM/f_wipe.c",
    "src/DOOM/g_game.c",
    "src/DOOM/hu_lib.c",
    "src/DOOM/hu_stuff.c",
    "src/DOOM/i_net.c",
    "src/DOOM/info.c",
    "src/DOOM/i_sound.c",
    "src/DOOM/i_system.c",
    "src/DOOM/i_video.c",
    "src/DOOM/m_argv.c",
    "src/DOOM/m_bbox.c",
    "src/DOOM/m_cheat.c",
    "src/DOOM/m_fixed.c",
    "src/DOOM/m_menu.c",
    "src/DOOM/m_misc.c",
    "src/DOOM/m_random.c",
    "src/DOOM/m_swap.c",
    "src/DOOM/p_ceilng.c",
    "src/DOOM/p_doors.c",
    "src/DOOM/p_enemy.c",
    "src/DOOM/p_floor.c",
    "src/DOOM/p_inter.c",
    "src/DOOM/p_lights.c",
    "src/DOOM/p_map.c",
    "src/DOOM/p_maputl.c",
    "src/DOOM/p_mobj.c",
    "src/DOOM/p_plats.c",
    "src/DOOM/p_pspr.c",
    "src/DOOM/p_saveg.c",
    "src/DOOM/p_setup.c",
    "src/DOOM/p_sight.c",
    "src/DOOM/p_spec.c",
    "src/DOOM/p_switch.c",
    "src/DOOM/p_telept.c",
    "src/DOOM/p_tick.c",
    "src/DOOM/p_user.c",
    "src/DOOM/r_bsp.c",
    "src/DOOM/r_data.c",
    "src/DOOM/r_draw.c",
    "src/DOOM/r_main.c",
    "src/DOOM/r_plane.c",
    "src/DOOM/r_segs.c",
    "src/DOOM/r_sky.c",
    "src/DOOM/r_things.c",
    "src/DOOM/sounds.c",
    "src/DOOM/s_sound.c",
    "src/DOOM/st_lib.c",
    "src/DOOM/st_stuff.c",
    "src/DOOM/tables.c",
    "src/DOOM/v_video.c",
    "src/DOOM/wi_stuff.c",
    "src/DOOM/w_wad.c",
    "src/DOOM/z_zone.c",
};
