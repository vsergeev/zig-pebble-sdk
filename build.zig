// zig-pebble-sdk v1.0.0
// https://github.com/vsergeev/zig-pebble-sdk

const std = @import("std");

////////////////////////////////////////////////////////////////////////////////
// Pebble Platform Constants
////////////////////////////////////////////////////////////////////////////////

pub const PebblePlatform = enum { aplite, basalt, chalk, diorite, emery, flint, gabbro };

const PebblePlatformParameters = struct {
    MAX_APP_BINARY_SIZE: usize,
    MAX_APP_MEMORY_SIZE: usize,
    MAX_WORKER_MEMORY_SIZE: usize,
    MAX_RESOURCES_SIZE_APPSTORE: usize,
    MAX_RESOURCES_SIZE: usize,
    MAX_FONT_GLYPH_SIZE: usize,
    DEFINES: []const []const u8,
};

const PEBBLE_PLATFORMS = std.EnumMap(PebblePlatform, PebblePlatformParameters).init(.{
    .aplite = .{
        .MAX_APP_BINARY_SIZE = 0x10000,
        .MAX_APP_MEMORY_SIZE = 0x6000,
        .MAX_WORKER_MEMORY_SIZE = 0x2800,
        .MAX_RESOURCES_SIZE_APPSTORE = 0x20000,
        .MAX_RESOURCES_SIZE = 0x80000,
        .MAX_FONT_GLYPH_SIZE = 256,
        .DEFINES = &.{ "PBL_PLATFORM_APLITE", "PBL_BW", "PBL_RECT", "PBL_COMPASS", "PBL_DISPLAY_WIDTH=144", "PBL_DISPLAY_HEIGHT=168" },
    },
    .basalt = .{
        .MAX_APP_BINARY_SIZE = 0x10000,
        .MAX_APP_MEMORY_SIZE = 0x10000,
        .MAX_WORKER_MEMORY_SIZE = 0x2800,
        .MAX_RESOURCES_SIZE_APPSTORE = 0x40000,
        .MAX_RESOURCES_SIZE = 0x100000,
        .MAX_FONT_GLYPH_SIZE = 256,
        .DEFINES = &.{ "PBL_PLATFORM_BASALT", "PBL_COLOR", "PBL_RECT", "PBL_MICROPHONE", "PBL_SMARTSTRAP", "PBL_HEALTH", "PBL_COMPASS", "PBL_SMARTSTRAP_POWER", "PBL_DISPLAY_WIDTH=144", "PBL_DISPLAY_HEIGHT=168" },
    },
    .chalk = .{
        .MAX_APP_BINARY_SIZE = 0x10000,
        .MAX_APP_MEMORY_SIZE = 0x10000,
        .MAX_WORKER_MEMORY_SIZE = 0x2800,
        .MAX_RESOURCES_SIZE_APPSTORE = 0x40000,
        .MAX_RESOURCES_SIZE = 0x100000,
        .MAX_FONT_GLYPH_SIZE = 256,
        .DEFINES = &.{ "PBL_PLATFORM_CHALK", "PBL_COLOR", "PBL_ROUND", "PBL_MICROPHONE", "PBL_SMARTSTRAP", "PBL_HEALTH", "PBL_COMPASS", "PBL_SMARTSTRAP_POWER", "PBL_DISPLAY_WIDTH=180", "PBL_DISPLAY_HEIGHT=180" },
    },
    .diorite = .{
        .MAX_APP_BINARY_SIZE = 0x10000,
        .MAX_APP_MEMORY_SIZE = 0x10000,
        .MAX_WORKER_MEMORY_SIZE = 0x2800,
        .MAX_RESOURCES_SIZE_APPSTORE = 0x40000,
        .MAX_RESOURCES_SIZE = 0x100000,
        .MAX_FONT_GLYPH_SIZE = 256,
        .DEFINES = &.{ "PBL_PLATFORM_DIORITE", "PBL_BW", "PBL_RECT", "PBL_MICROPHONE", "PBL_HEALTH", "PBL_SMARTSTRAP", "PBL_DISPLAY_WIDTH=144", "PBL_DISPLAY_HEIGHT=168" },
    },
    .emery = .{
        .MAX_APP_BINARY_SIZE = 0x20000,
        .MAX_APP_MEMORY_SIZE = 0x20000,
        .MAX_WORKER_MEMORY_SIZE = 0x2800,
        .MAX_RESOURCES_SIZE_APPSTORE = 0x40000,
        .MAX_RESOURCES_SIZE = 0x100000,
        .MAX_FONT_GLYPH_SIZE = 512,
        .DEFINES = &.{ "PBL_PLATFORM_EMERY", "PBL_COLOR", "PBL_RECT", "PBL_MICROPHONE", "PBL_SMARTSTRAP", "PBL_HEALTH", "PBL_SMARTSTRAP_POWER", "PBL_COMPASS", "PBL_DISPLAY_WIDTH=200", "PBL_DISPLAY_HEIGHT=228" },
    },
    .flint = .{
        .MAX_APP_BINARY_SIZE = 0x10000,
        .MAX_APP_MEMORY_SIZE = 0x10000,
        .MAX_WORKER_MEMORY_SIZE = 0x2800,
        .MAX_RESOURCES_SIZE_APPSTORE = 0x40000,
        .MAX_RESOURCES_SIZE = 0x100000,
        .MAX_FONT_GLYPH_SIZE = 256,
        .DEFINES = &.{ "PBL_PLATFORM_FLINT", "PBL_BW", "PBL_RECT", "PBL_MICROPHONE", "PBL_HEALTH", "PBL_COMPASS", "PBL_DISPLAY_WIDTH=144", "PBL_DISPLAY_HEIGHT=168" },
    },
    .gabbro = .{
        .MAX_APP_BINARY_SIZE = 0x20000,
        .MAX_APP_MEMORY_SIZE = 0x20000,
        .MAX_WORKER_MEMORY_SIZE = 0x2800,
        .MAX_RESOURCES_SIZE_APPSTORE = 0x40000,
        .MAX_RESOURCES_SIZE = 0x100000,
        .MAX_FONT_GLYPH_SIZE = 512,
        .DEFINES = &.{ "PBL_PLATFORM_GABBRO", "PBL_COLOR", "PBL_ROUND", "PBL_MICROPHONE", "PBL_HEALTH", "PBL_COMPASS", "PBL_DISPLAY_WIDTH=260", "PBL_DISPLAY_HEIGHT=260" },
    },
});

////////////////////////////////////////////////////////////////////////////////
// Pebble SDK Paths
////////////////////////////////////////////////////////////////////////////////

const PebbleSDKPaths = struct {
    toolchain_bin_path: []const u8,
    toolchain_include_path: []const u8,
    pebble_include_path: []const u8,
    pebble_static_library_path: []const u8,
    pebble_linker_script_template_path: []const u8,
};

fn pebble_sdk_paths(b: *std.Build, pebble_sdk_path: []const u8, platform: PebblePlatform) PebbleSDKPaths {
    // Construct various pebble sdk subpaths
    const toolchain_bin_path = b.pathJoin(&.{ pebble_sdk_path, "toolchain/arm-none-eabi/bin" });
    const toolchain_include_path = b.pathJoin(&.{ pebble_sdk_path, "toolchain/arm-none-eabi/arm-none-eabi/include" });
    const pebble_include_path = b.pathJoin(&.{ pebble_sdk_path, "sdk-core/pebble", @tagName(platform), "include" });
    const pebble_static_library_path = b.pathJoin(&.{ pebble_sdk_path, "sdk-core/pebble", @tagName(platform), "lib/libpebble.a" });
    const pebble_linker_script_template_path = b.pathJoin(&.{ pebble_sdk_path, "sdk-core/pebble/common/pebble_app.ld.template" });

    return .{
        .toolchain_bin_path = toolchain_bin_path,
        .toolchain_include_path = toolchain_include_path,
        .pebble_include_path = pebble_include_path,
        .pebble_static_library_path = pebble_static_library_path,
        .pebble_linker_script_template_path = pebble_linker_script_template_path,
    };
}

////////////////////////////////////////////////////////////////////////////////
// Pebble Header Fixup
////////////////////////////////////////////////////////////////////////////////

fn pebble_header_fixup(b: *std.Build, pebble_include_path: []const u8) []const u8 {
    var pebble_header = std.fs.cwd().readFileAlloc(b.allocator, b.pathJoin(&.{ pebble_include_path, "pebble.h" }), 1 << 20) catch @panic("OOM");

    // Remove code-generated message key and resource ids headers (these will
    // be code generated by this build script later)
    pebble_header = std.mem.replaceOwned(u8, b.allocator, pebble_header, "#include \"message_keys.auto.h\"\n", "") catch @panic("OOM");
    pebble_header = std.mem.replaceOwned(u8, b.allocator, pebble_header, "#include \"src/resource_ids.auto.h\"\n", "") catch @panic("OOM");

    // Bitfields need to be removed, as they are currently unsupported by Zig Translate C

    // Remove RBGA bitfield in union GColor8
    pebble_header = std.mem.replaceOwned(u8, b.allocator, pebble_header,
        \\typedef union GColor8 {
        \\  uint8_t argb;
        \\  struct {
        \\    uint8_t b:2; //!< Blue
        \\    uint8_t g:2; //!< Green
        \\    uint8_t r:2; //!< Red
        \\    uint8_t a:2; //!< Alpha. 3 = 100% opaque, 2 = 66% opaque, 1 = 33% opaque, 0 = transparent.
        \\  };
        \\} GColor8;
    , "typedef struct GColor8 { uint8_t argb; } GColor8;") catch @panic("OOM");

    // Replace GColorFromRGBA macro from gcolor_definitions.h
    pebble_header = std.mem.replaceOwned(u8, b.allocator, pebble_header,
        \\#include "gcolor_definitions.h"
    ,
        \\#define GColorFromRGBA(red, green, blue, alpha) ((GColor8){.argb = (((alpha >> 6) << 6) | ((red >> 6) << 4) | ((green >> 6) << 2) | (blue >> 6))})
        \\#include "gcolor_definitions.h"
    ) catch @panic("OOM");

    // Replace bitfields with uint8_t in HealthMinuteData
    pebble_header = std.mem.replaceOwned(u8, b.allocator, pebble_header,
        \\  bool is_invalid: 1;         //!< `true` if the item doesn't represents actual data
        \\                              //!< and should be ignored.
        \\  AmbientLightLevel light: 3; //!< Instantaneous light level during this minute.
        \\  uint8_t padding: 4;
    , "  uint8_t is_invalid_and_light_level;") catch @panic("OOM");

    // Replace type bitfield with uint8_t in Tuple
    pebble_header = std.mem.replaceOwned(u8, b.allocator, pebble_header,
        \\  TupleType type:8;
    , "  uint8_t type;") catch @panic("OOM");

    return pebble_header;
}

////////////////////////////////////////////////////////////////////////////////
// Pebble App Linker Script Templating
////////////////////////////////////////////////////////////////////////////////

fn pebble_linker_script_template(b: *std.Build, pebble_linker_script_template_path: []const u8, platform: PebblePlatform) []const u8 {
    const linker_script = std.fs.cwd().readFileAlloc(b.allocator, pebble_linker_script_template_path, 1 << 20) catch @panic("OOM");

    // Template max app memory size
    return std.mem.replaceOwned(u8, b.allocator, linker_script, "@MAX_APP_MEMORY_SIZE@", b.fmt("0x{X}", .{PEBBLE_PLATFORMS.getAssertContains(platform).MAX_APP_MEMORY_SIZE})) catch @panic("OOM");
}

////////////////////////////////////////////////////////////////////////////////
// Pebble App IDs Templating
////////////////////////////////////////////////////////////////////////////////

fn pebble_appids_zig_template(b: *std.Build, platform: PebblePlatform, metadata: PebbleAppMetadata) []const u8 {
    // Collect message keys
    var message_key_ids = std.array_list.Managed(u8).init(b.allocator);
    for (metadata.messageKeys) |message_key| {
        message_key_ids.appendSlice(b.fmt("    {s} = {d},\n", .{ message_key.key, message_key.value })) catch @panic("OOM");
    }

    // Collect media
    var resource_ids = std.array_list.Managed(u8).init(b.allocator);
    var id: usize = 1;
    for (metadata.resources.media) |resource| {
        if (resource.targetPlatforms()) |targetPlatforms| if (!std.mem.containsAtLeastScalar(PebblePlatform, targetPlatforms, 1, platform)) continue;
        resource_ids.appendSlice(b.fmt("    {s} = {d},\n", .{ resource.name(), id })) catch @panic("OOM");
        id += 1;
    }

    // Collect published media
    var published_ids = std.array_list.Managed(u8).init(b.allocator);
    for (metadata.resources.publishedMedia) |published_resource| {
        published_ids.appendSlice(b.fmt("    {s} = {d},\n", .{ published_resource.name, published_resource.id })) catch @panic("OOM");
    }

    return b.fmt(
        \\pub const MESSAGE_KEYS = enum(u32) {{
        \\{s}}};
        \\
        \\pub const RESOURCE_IDS = enum(u32) {{
        \\{s}}};
        \\
        \\pub const PUBLISHED_IDS = enum(u32) {{
        \\{s}}};
    , .{ message_key_ids.items, resource_ids.items, published_ids.items });
}

////////////////////////////////////////////////////////////////////////////////
// Pebble App Info Templating
////////////////////////////////////////////////////////////////////////////////

fn pebble_menu_icon_resource_id(platform: PebblePlatform, metadata: PebbleAppMetadata) usize {
    // Find resource id of bitmap with menuIcon set to true
    var id: usize = 1;
    for (metadata.resources.media) |resource| {
        if (resource.targetPlatforms()) |targetPlatforms| if (!std.mem.containsAtLeastScalar(PebblePlatform, targetPlatforms, 1, platform)) continue;
        switch (resource) {
            .bitmap => |bitmap| if (bitmap.menuIcon) |menuIcon| if (menuIcon) return id,
            else => {},
        }
        id += 1;
    }

    return 0;
}

fn uuidToBytes(b: *std.Build, uuid: []const u8) [16]u8 {
    const hex = std.mem.replaceOwned(u8, b.allocator, uuid, "-", "") catch @panic("OOM");
    if (hex.len != 32) @panic("Invalid UUID");
    return (std.fmt.hexToBytes(b.allocator.alloc(u8, 16) catch @panic("OOM"), hex) catch @panic("Invalid UUID"))[0..16].*;
}

fn pebble_appinfo_zig_template(b: *std.Build, platform: PebblePlatform, metadata: PebbleAppMetadata) []const u8 {
    // Lookup menu icon resource id
    const icon_resource_id = pebble_menu_icon_resource_id(platform, metadata);

    // Assemble flags
    var flags = b.fmt("pebble_process_info.PROCESS_INFO_PLATFORM_{s}", .{std.ascii.allocUpperString(b.allocator, @tagName(platform)) catch @panic("OOM")});
    if (metadata.watchapp.watchface) flags = b.fmt("{s} | pebble_process_info.PROCESS_INFO_WATCH_FACE", .{flags});
    if (metadata.watchapp.hiddenApp) flags = b.fmt("{s} | pebble_process_info.PROCESS_INFO_VISIBILITY_HIDDEN", .{flags});
    if (metadata.watchapp.onlyShownOnCommunication) flags = b.fmt("{s} | pebble_process_info.PROCESS_INFO_VISIBILITY_SHOWN_ON_COMMUNICATION", .{flags});

    // Convert UUID string to bytes
    const uuid_bytes = uuidToBytes(b, metadata.uuid);

    return b.fmt(
        \\const pebble_process_info = @import("pebble_process_info");
        \\export const __pbl_app_info: pebble_process_info.PebbleProcessInfo linksection(".pbl_header") = .{{
        \\    .header = .{{ 'P', 'B', 'L', 'A', 'P', 'P', 0x00, 0x00 }},
        \\    .struct_version = .{{ .major = pebble_process_info.PROCESS_INFO_CURRENT_STRUCT_VERSION_MAJOR, .minor = pebble_process_info.PROCESS_INFO_CURRENT_STRUCT_VERSION_MINOR }},
        \\    .sdk_version = .{{ .major = pebble_process_info.PROCESS_INFO_CURRENT_SDK_VERSION_MAJOR, .minor = pebble_process_info.PROCESS_INFO_CURRENT_SDK_VERSION_MINOR }},
        \\    .process_version = .{{ .major = {d}, .minor = {d} }},
        \\    .load_size = 0xb6b6,
        \\    .offset = 0xb6b6b6b6,
        \\    .crc = 0xb6b6b6b6,
        \\    .name = ("{s}" ++ [_]u8{{0}} ** (pebble_process_info.PROCESS_NAME_BYTES - {d})).*,
        \\    .company = ("{s}" ++ [_]u8{{0}} ** (pebble_process_info.COMPANY_NAME_BYTES - {d})).*,
        \\    .icon_resource_id = {d},
        \\    .sym_table_addr = 0xA7A7A7A7,
        \\    .flags = {s},
        \\    .num_reloc_entries = 0xdeadcafe,
        \\    .uuid = .{{ .byte0 = 0x{X:0>2}, .byte1 = 0x{X:0>2}, .byte2 = 0x{X:0>2}, .byte3 = 0x{X:0>2}, .byte4 = 0x{X:0>2}, .byte5 = 0x{X:0>2}, .byte6 = 0x{X:0>2}, .byte7 = 0x{X:0>2}, .byte8 = 0x{X:0>2}, .byte9 = 0x{X:0>2}, .byte10 = 0x{X:0>2}, .byte11 = 0x{X:0>2}, .byte12 = 0x{X:0>2}, .byte13 = 0x{X:0>2}, .byte14 = 0x{X:0>2}, .byte15 = 0x{X:0>2} }},
        \\    .virtual_size = 0xb6b6,
        \\}};
    , .{ metadata.version.major, metadata.version.minor, metadata.displayName, metadata.displayName.len, metadata.author, metadata.author.len, icon_resource_id, flags, uuid_bytes[0], uuid_bytes[1], uuid_bytes[2], uuid_bytes[3], uuid_bytes[4], uuid_bytes[5], uuid_bytes[6], uuid_bytes[7], uuid_bytes[8], uuid_bytes[9], uuid_bytes[10], uuid_bytes[11], uuid_bytes[12], uuid_bytes[13], uuid_bytes[14], uuid_bytes[15] });
}

////////////////////////////////////////////////////////////////////////////////
// Pebble App Info JSON Templating
////////////////////////////////////////////////////////////////////////////////

const PebbleAppinfoObject = struct {
    name: []const u8,
    displayName: []const u8,
    shortName: []const u8,
    longName: []const u8,
    versionLabel: []const u8,
    uuid: []const u8,
    sdkVersion: []const u8,
    targetPlatforms: []const PebblePlatform,
    enableMultiJS: bool,
    watchapp: @FieldType(PebbleAppMetadata, "watchapp"),
    appKeys: std.json.ArrayHashMap(u32),
    messageKeys: std.json.ArrayHashMap(u32),
    resources: @FieldType(PebbleAppMetadata, "resources"),
    capabilities: []const PebbleCapability,
};

fn pebble_appinfo_json_template(b: *std.Build, name: []const u8, metadata: PebbleAppMetadata) []const u8 {
    var message_keys_map = std.json.ArrayHashMap(u32){};
    for (metadata.messageKeys) |message_key| {
        message_keys_map.map.put(b.allocator, message_key.key, message_key.value) catch @panic("OOM");
    }

    const appinfo_object: PebbleAppinfoObject = .{
        .name = name,
        .displayName = metadata.displayName,
        .shortName = metadata.displayName,
        .longName = metadata.displayName,
        .versionLabel = b.fmt("{d}.{d}.0", .{ metadata.version.major, metadata.version.minor }),
        .uuid = metadata.uuid,
        .sdkVersion = b.fmt("{d}", .{metadata.sdkVersion}),
        .targetPlatforms = metadata.targetPlatforms,
        .enableMultiJS = metadata.enableMultiJS,
        .watchapp = metadata.watchapp,
        .appKeys = message_keys_map,
        .messageKeys = message_keys_map,
        .resources = metadata.resources,
        .capabilities = metadata.capabilities,
    };
    return std.json.Stringify.valueAlloc(b.allocator, appinfo_object, .{}) catch @panic("OOM");
}

////////////////////////////////////////////////////////////////////////////////
// Pebble Application Build Helper
////////////////////////////////////////////////////////////////////////////////

pub const PebbleCapability = enum { location, configurable, health };

pub const PebbleAppMessageKey = struct {
    key: []const u8,
    value: u32,
};

pub const PebbleAppMedia = union(enum) {
    bitmap: struct {
        name: []const u8,
        file: []const u8,
        targetPlatforms: ?[]const PebblePlatform = null,
        menuIcon: ?bool = null,
        storageFormat: ?enum { pbi, png } = null,
        memoryFormat: ?enum { Smallest, SmallestPalette, @"1Bit", @"8Bit", @"1BitPalette", @"2BitPalette", @"4BitPalette" } = null,
        spaceOptimization: ?enum { storage, memory } = null,
    },
    font: struct {
        name: []const u8,
        file: []const u8,
        targetPlatforms: ?[]const PebblePlatform = null,
        characterRegex: ?[]const u8 = null,
    },
    raw: struct {
        name: []const u8,
        file: []const u8,
        targetPlatforms: ?[]const PebblePlatform = null,
    },

    // Getters to access common fields across union

    pub fn name(self: PebbleAppMedia) []const u8 {
        return switch (self) {
            inline else => |resource| resource.name,
        };
    }

    pub fn file(self: PebbleAppMedia) []const u8 {
        return switch (self) {
            inline else => |resource| resource.file,
        };
    }

    pub fn targetPlatforms(self: PebbleAppMedia) ?[]const PebblePlatform {
        return switch (self) {
            inline else => |resource| resource.targetPlatforms,
        };
    }

    pub fn jsonStringify(value: @This(), jws: anytype) !void {
        return switch (value) {
            inline else => |resource, tag| {
                try jws.beginObject();
                try jws.objectField("type");
                try jws.write(tag);
                inline for (std.meta.fields(@TypeOf(resource))) |Field| {
                    if (@typeInfo(Field.type) != .optional or @field(resource, Field.name) != null) {
                        try jws.objectField(Field.name);
                        try jws.write(@field(resource, Field.name));
                    }
                }
                try jws.endObject();
            },
        };
    }
};

pub const PebbleAppPublishedMedia = struct {
    name: []const u8,
    id: u32,
    alias: ?[]const u8 = null,
    glance: ?[]const u8 = null,
    timeline: ?struct {
        tiny: []const u8,
        small: []const u8,
        lage: []const u8,
    } = null,

    pub fn jsonStringify(value: @This(), jws: anytype) !void {
        try jws.beginObject();
        inline for (std.meta.fields(@This())) |Field| {
            if (@typeInfo(Field.type) != .optional or @field(value, Field.name) != null) {
                try jws.objectField(Field.name);
                try jws.write(@field(value, Field.name));
            }
        }
        try jws.endObject();
    }
};

pub const PebbleAppMetadata = struct {
    displayName: []const u8,
    author: []const u8,
    uuid: []const u8,
    version: struct { major: u8, minor: u8 },
    sdkVersion: usize = 3,
    targetPlatforms: []const PebblePlatform,
    enableMultiJS: bool = false,
    watchapp: struct {
        watchface: bool = false,
        hiddenApp: bool = false,
        onlyShownOnCommunication: bool = false,
    } = .{},
    capabilities: []const PebbleCapability = &.{},
    messageKeys: []const PebbleAppMessageKey = &.{},
    resources: struct {
        media: []const PebbleAppMedia = &.{},
        publishedMedia: []const PebbleAppPublishedMedia = &.{},
    } = .{},
};

pub const PebbleApplicationOptions = struct {
    name: []const u8,
    pebble: PebbleAppMetadata,
    root_source_file: std.Build.LazyPath,
    optimize: std.builtin.OptimizeMode = .ReleaseSafe,
};

pub fn addPebbleApplication(b: *std.Build, options: PebbleApplicationOptions) void {
    // Resolve pebble target and optimize
    const target = b.resolveTargetQuery(.{ .cpu_arch = .thumb, .os_tag = .freestanding, .abi = .eabi, .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m3 } });
    const optimize = options.optimize;

    // Look up pebble sdk path
    const pebble_sdk_path = b.option([]const u8, "pebble_sdk_path", "Pebble SDK path (default ~/.pebble-sdk/SDKs/current/)") orelse path: {
        if (std.posix.getenv("HOME")) |home_path| {
            break :path b.pathJoin(&.{ home_path, ".pebble-sdk/SDKs/current" });
        } else {
            std.debug.panic("Unable to determine Pebble SDK path. Please set the 'pebble_sdk_path' build option.", .{});
        }
    };

    // Create app artifacts list
    var pebble_app_artifacts = std.array_list.Managed(struct {
        platform: PebblePlatform,
        bin_step: *std.Build.Step,
        bin_file: std.Build.LazyPath,
        resources_step: *std.Build.Step,
        resources_file: std.Build.LazyPath,
    }).init(b.allocator);

    // For each pebble platform
    for (options.pebble.targetPlatforms) |platform| {
        // Lookup SDK paths for this platform
        const paths = pebble_sdk_paths(b, pebble_sdk_path, platform);

        // Translate pebble.h
        const translate_pebble = b.addTranslateC(.{
            .root_source_file = b.addWriteFiles().add("pebble.h", pebble_header_fixup(b, paths.pebble_include_path)),
            .target = target,
            .optimize = optimize,
        });
        translate_pebble.defineCMacroRaw("_TIME_H_");
        translate_pebble.defineCMacroRaw("time_t=long");
        for (PEBBLE_PLATFORMS.getAssertContains(platform).DEFINES) |platform_define| translate_pebble.defineCMacroRaw(platform_define);
        translate_pebble.addIncludePath(.{ .cwd_relative = paths.pebble_include_path });
        translate_pebble.addSystemIncludePath(.{ .cwd_relative = paths.toolchain_include_path });
        translate_pebble.link_libc = false;

        // Create pebble module with pebble static library
        const translate_pebble_mod = translate_pebble.addModule("pebble");
        translate_pebble_mod.addObjectFile(.{ .cwd_relative = paths.pebble_static_library_path });

        // Translate pebble_process_info.h
        const translate_pebble_process_info = b.addTranslateC(.{
            .root_source_file = .{ .cwd_relative = b.pathJoin(&.{ paths.pebble_include_path, "pebble_process_info.h" }) },
            .target = target,
            .optimize = optimize,
        });
        translate_pebble_process_info.addSystemIncludePath(.{ .cwd_relative = paths.toolchain_include_path });
        translate_pebble_process_info.link_libc = false;

        // Create pebble_process_info module
        const translate_pebble_process_info_mod = translate_pebble_process_info.addModule("pebble_process_info");

        // Code generate pebble_appids module
        const pebble_appids_mod = b.createModule(.{
            .root_source_file = b.addWriteFiles().add(b.fmt("{s}_appids.gen.zig", .{options.name}), pebble_appids_zig_template(b, platform, options.pebble)),
            .target = target,
            .optimize = optimize,
            .pic = true,
            .unwind_tables = .none,
        });
        b.getInstallStep().dependOn(&b.addInstallFile(pebble_appids_mod.root_source_file.?, b.fmt("{s}/{s}_appids.gen.zig", .{ @tagName(platform), options.name })).step);

        // Generate linker script
        const linker_script_step = b.addWriteFiles();
        const linker_script = linker_script_step.add(b.fmt("{s}.gen.ld", .{options.name}), pebble_linker_script_template(b, paths.pebble_linker_script_template_path, platform));

        // Create root module with injected pebble and pebble_appids imports and target options
        const root_module = b.createModule(.{
            .root_source_file = options.root_source_file,
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "pebble", .module = translate_pebble_mod },
                .{ .name = "pebble_appids", .module = pebble_appids_mod },
            },
            .strip = false,
            .pic = true,
            .unwind_tables = .none,
        });

        // Code generate appinfo object
        const appinfo_object = b.addObject(.{
            .name = "pebble_appinfo",
            .root_module = b.createModule(.{
                .root_source_file = b.addWriteFiles().add(b.fmt("{s}_appinfo.gen.zig", .{options.name}), pebble_appinfo_zig_template(b, platform, options.pebble)),
                .imports = &.{
                    .{ .name = "pebble_process_info", .module = translate_pebble_process_info_mod },
                },
                .target = target,
                .optimize = optimize,
                .strip = false,
                .pic = true,
                .unwind_tables = .none,
            }),
        });

        // Add executable with appinfo object and linker script
        const exe = b.addExecutable(.{
            .name = b.fmt("{s}.elf", .{options.name}),
            .root_module = root_module,
        });
        exe.addObject(appinfo_object);
        exe.setLinkerScript(linker_script);
        exe.entry = .{ .symbol_name = "main" };
        b.build_id = .sha1;
        exe.step.dependOn(&linker_script_step.step);
        b.getInstallStep().dependOn(&b.addInstallArtifact(exe, .{ .dest_dir = .{ .override = .prefix }, .dest_sub_path = b.fmt("{s}/{s}.elf", .{ @tagName(platform), options.name }) }).step);

        // Extract binary with objcopy
        const objcopy_bin_step = b.addSystemCommand(&.{ b.pathJoin(&.{ paths.toolchain_bin_path, "arm-none-eabi-objcopy" }), "-S", "-R", ".stack", "-R", ".priv_bss", "-R", ".bss", "-R", ".retained", "-O", "binary" });
        objcopy_bin_step.addFileArg(exe.getEmittedBin());
        const raw_bin_file = objcopy_bin_step.addOutputFileArg(b.fmt("{s}.raw.bin", .{options.name}));
        objcopy_bin_step.step.dependOn(&exe.step);

        // Pack resources
        const pack_resources_step = b.addSystemCommand(&.{ "uv", "tool", "run", "--from", "pebble-tool", "python", "-c", "import sys; from pbpack import ResourcePack; pack = ResourcePack(False); [pack.add_resource(open(path, 'rb').read()) for path in sys.argv[2:]]; pack.serialize(open(sys.argv[1], 'wb'))" });
        pack_resources_step.setEnvironmentVariable("PYTHONPATH", b.pathJoin(&.{ pebble_sdk_path, "sdk-core/pebble/common/tools" }));
        const resources_file = pack_resources_step.addOutputFileArg(b.fmt("{s}_resources.pbpack", .{options.name}));
        for (options.pebble.resources.media) |resource| {
            if (resource.targetPlatforms()) |targetPlatforms| if (!std.mem.containsAtLeastScalar(PebblePlatform, targetPlatforms, 1, platform)) continue;

            switch (resource) {
                .font => |font| {
                    // Convert ttf font into Pebble font format
                    const convert_font_step = b.addSystemCommand(&.{ "uv", "tool", "run", "--from", "pebble-tool", "python", "-c", "import sys; from font.fontgen import Font, MAX_GLYPHS; import re; height = re.search(r'\\d+', sys.argv[3]); height is None and (_ for _ in ()).throw(ValueError(f'Missing height in font name \"{sys.argv[3]}\"')); font = Font(sys.argv[2], int(height[0]), MAX_GLYPHS, int(sys.argv[4]), False); font.set_regex_filter(sys.argv[5]) if len(sys.argv) > 5 else None; font.build_tables(); open(sys.argv[1], 'wb').write(font.bitstring())" });
                    convert_font_step.setEnvironmentVariable("PYTHONPATH", b.pathJoin(&.{ pebble_sdk_path, "sdk-core/pebble/common/tools" }));
                    const pebble_font_file = convert_font_step.addOutputFileArg(b.fmt("{s}.reso", .{font.name}));
                    convert_font_step.addFileArg(b.path(b.pathJoin(&.{ "resources", font.file })));
                    convert_font_step.addArg(font.name);
                    convert_font_step.addArg(b.fmt("{d}", .{PEBBLE_PLATFORMS.getAssertContains(platform).MAX_FONT_GLYPH_SIZE}));
                    if (font.characterRegex) |characterRegex| convert_font_step.addArg(characterRegex);
                    pack_resources_step.addFileArg(pebble_font_file);
                    pack_resources_step.step.dependOn(&convert_font_step.step);
                },
                else => {
                    // Other resource types get packed directly
                    pack_resources_step.addFileArg(b.path(b.pathJoin(&.{ "resources", resource.file() })));
                },
            }
        }
        b.getInstallStep().dependOn(&b.addInstallFile(resources_file, b.fmt("{s}/{s}_resources.pbpack", .{ @tagName(platform), options.name })).step);

        // Inject metadata into binary
        const inject_metadata_step = b.addSystemCommand(&.{ "uv", "tool", "run", "--from", "pebble-tool", "python", "-c", "import sys; import time; import shutil; from inject_metadata import inject_metadata; shutil.copy(sys.argv[1], sys.argv[4]); inject_metadata(sys.argv[4], sys.argv[2], sys.argv[3], int(time.time()))" });
        inject_metadata_step.setEnvironmentVariable("PYTHONPATH", b.pathJoin(&.{ pebble_sdk_path, "sdk-core/pebble/common/tools" }));
        inject_metadata_step.addFileArg(raw_bin_file);
        inject_metadata_step.addFileArg(exe.getEmittedBin());
        inject_metadata_step.addFileArg(resources_file);
        const bin_file = inject_metadata_step.addOutputFileArg(b.fmt("{s}.bin", .{options.name}));
        inject_metadata_step.step.dependOn(&pack_resources_step.step);
        inject_metadata_step.step.dependOn(&objcopy_bin_step.step);
        b.getInstallStep().dependOn(&b.addInstallFile(bin_file, b.fmt("{s}/{s}.bin", .{ @tagName(platform), options.name })).step);

        // Add artifact info to artifacts
        pebble_app_artifacts.append(.{
            .platform = platform,
            .bin_step = &inject_metadata_step.step,
            .bin_file = bin_file,
            .resources_step = &pack_resources_step.step,
            .resources_file = resources_file,
        }) catch @panic("OOM");
    }

    // Code generate appinfo json
    const appinfo_json_step = b.addWriteFiles();
    const appinfo_json_file = appinfo_json_step.add("appinfo.json", pebble_appinfo_json_template(b, options.name, options.pebble));
    b.getInstallStep().dependOn(&b.addInstallFile(appinfo_json_file, b.fmt("{s}_appinfo.json", .{options.name})).step);

    // Package appinfo, binaries, and resources into pbw
    const package_pbw_step = b.addSystemCommand(&.{ "uv", "tool", "run", "--from", "pebble-tool", "python", "-c", "import sys; import time; import json; from mkbundle import make_watchapp_bundle; make_watchapp_bundle(int(time.time()), sys.argv[1], [{'subfolder': sys.argv[i], 'sdk_version': dict(zip(['major','minor'], open(sys.argv[i+1], 'rb').read(80)[10:12])), 'watchapp': sys.argv[i+1], 'resources': sys.argv[i+2], 'worker_bin': None} for i in range(3, len(sys.argv), 3)], [], outfile=sys.argv[2])" });
    package_pbw_step.setEnvironmentVariable("PYTHONPATH", b.pathJoin(&.{ pebble_sdk_path, "sdk-core/pebble/common/tools" }));
    package_pbw_step.addFileArg(appinfo_json_file);
    const pbw_file = package_pbw_step.addOutputFileArg(b.fmt("{s}.pbw", .{options.name}));
    for (pebble_app_artifacts.items) |artifact| {
        package_pbw_step.addArg(@tagName(artifact.platform));
        package_pbw_step.addFileArg(artifact.bin_file);
        package_pbw_step.addFileArg(artifact.resources_file);
        package_pbw_step.step.dependOn(artifact.bin_step);
        package_pbw_step.step.dependOn(artifact.resources_step);
    }
    package_pbw_step.step.dependOn(&appinfo_json_step.step);
    b.getInstallStep().dependOn(&b.addInstallFile(pbw_file, b.fmt("{s}.pbw", .{options.name})).step);

    // Top-level install step
    b.getInstallStep().dependOn(&package_pbw_step.step);

    // Top-level step to upload to emulator or watch
    const upload_step = b.step("upload", "Upload the Pebble App to emulator or watch");
    const run_upload_step = b.addSystemCommand(&.{ "uv", "tool", "run", "--from", "pebble", "pebble", "install" });
    run_upload_step.addArg(b.getInstallPath(.prefix, b.fmt("{s}.pbw", .{options.name})));
    run_upload_step.step.dependOn(b.getInstallStep());
    upload_step.dependOn(&run_upload_step.step);
    if (b.args) |args| {
        run_upload_step.addArgs(args);
    }
}
