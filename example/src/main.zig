const std = @import("std");

const pebble = @import("pebble");
const pebble_appids = @import("pebble_appids");

var s_window: ?*pebble.Window = null;
var s_time_layer: ?*pebble.TextLayer = null;
var s_time_buf: [16]u8 = undefined;
var s_bitmap: ?*pebble.GBitmap = null;
var s_bitmap_layer: ?*pebble.BitmapLayer = null;

fn tick_handler(tick_time: ?*pebble.tm, _: pebble.TimeUnits) callconv(.c) void {
    pebble.text_layer_set_text(s_time_layer, std.fmt.bufPrintZ(&s_time_buf, "{d:0>2}:{d:0>2}:{d:0>2}", .{
        @as(usize, @intCast(tick_time.?.tm_hour)),
        @as(usize, @intCast(tick_time.?.tm_min)),
        @as(usize, @intCast(tick_time.?.tm_sec)),
    }) catch unreachable);
}

fn window_load(window: ?*pebble.Window) callconv(.c) void {
    const window_layer = pebble.window_get_root_layer(window);
    const bounds = pebble.layer_get_bounds(window_layer);

    s_time_layer = pebble.text_layer_create(.{ .origin = .{ .x = 0, .y = @divTrunc(bounds.size.h, 2) - 25 }, .size = .{ .w = bounds.size.w, .h = 50 } });

    pebble.text_layer_set_text_color(s_time_layer, pebble.GColorChromeYellow);
    pebble.text_layer_set_font(s_time_layer, pebble.fonts_get_system_font(pebble.FONT_KEY_BITHAM_42_BOLD));
    pebble.text_layer_set_text_alignment(s_time_layer, pebble.GTextAlignmentCenter);

    s_bitmap = pebble.gbitmap_create_with_resource(@intFromEnum(pebble_appids.RESOURCE_IDS.IMAGE_FISH));
    s_bitmap_layer = pebble.bitmap_layer_create(.{ .origin = .{ .x = @divTrunc(bounds.size.w, 2) - 25, .y = 25 }, .size = .{ .w = 50, .h = 50 } });

    pebble.bitmap_layer_set_compositing_mode(s_bitmap_layer, pebble.GCompOpSet);
    pebble.bitmap_layer_set_bitmap(s_bitmap_layer, s_bitmap);

    pebble.layer_add_child(window_layer, pebble.text_layer_get_layer(s_time_layer));
    pebble.layer_add_child(window_layer, pebble.bitmap_layer_get_layer(s_bitmap_layer));
}

fn window_unload(_: ?*pebble.Window) callconv(.c) void {
    pebble.text_layer_destroy(s_time_layer);
    pebble.gbitmap_destroy(s_bitmap);
    pebble.bitmap_layer_destroy(s_bitmap_layer);
}

fn init() void {
    s_window = pebble.window_create();

    pebble.window_set_window_handlers(s_window, .{
        .load = window_load,
        .unload = window_unload,
    });

    pebble.window_stack_push(s_window, true);

    pebble.tick_timer_service_subscribe(pebble.SECOND_UNIT, tick_handler);
}

fn deinit() void {
    pebble.window_destroy(s_window);
}

export fn main() void {
    init();
    pebble.app_event_loop();
    deinit();
}
