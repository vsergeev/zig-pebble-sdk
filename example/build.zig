const std = @import("std");

const pebble_sdk = @import("pebble_sdk");

pub fn build(b: *std.Build) !void {
    pebble_sdk.addPebbleApplication(b, .{
        .name = "watchface_example",
        .pebble = .{
            .displayName = "Watchface with Fish",
            .author = "Example",
            .uuid = "128b668f-100a-47d7-9009-d35a6b513f6b",
            .version = .{ .major = 1, .minor = 0 },
            .targetPlatforms = &.{ .emery, .gabbro },
            .watchapp = .{
                .watchface = true,
            },
            .resources = .{
                .media = &.{
                    .{ .bitmap = .{ .name = "IMAGE_FISH", .file = "fish.png" } },
                },
            },
        },
        .root_source_file = b.path("src/main.zig"),
        .optimize = .ReleaseSmall,
    });
}
