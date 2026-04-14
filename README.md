# zig-pebble-sdk

Build Pebble watchapps and watchfaces entirely in Zig.

Applications have access to the Pebble C API and the C standard library, as
well as the Zig standard library.

See the included [example watchface](example/) or follow the quickstart below.

zig-pebble-sdk requires Zig version 0.15 and the Pebble SDK.

## Quickstart

**Install the Pebble SDK:** https://developer.repebble.com/sdk/

zig-pebble-sdk uses the header files, the `libpebble` static library, and
several tools packaged with the SDK.

**Create an empty Zig project:**

```
$ mkdir pebble-watchface
$ cd pebble-watchface
$ zig init -m
```

**Fetch the `zig-pebble-sdk` package into your Zig project:**

```
$ zig fetch --save git+https://github.com/vsergeev/zig-pebble-sdk#master
```

**Define a Pebble application in your `build.zig`:**

```zig
// build.zig
const std = @import("std");

const pebble_sdk = @import("pebble_sdk");

pub fn build(b: *std.Build) !void {
    pebble_sdk.addPebbleApplication(b, .{
        .name = "watchface_example",
        .pebble = .{
            .displayName = "Watchface Example",
            .author = "Example",
            .uuid = "5357881f-9d4a-48b9-9f0f-5ff138a6e936", // Generate with uuidgen
            .version = .{ .major = 1, .minor = 0 },
            .targetPlatforms = &.{ .emery, .gabbro }, // Pebble platforms to build for
            .watchapp = .{
                .watchface = true,
            },
          },
        .root_source_file = b.path("src/main.zig"),
        .optimize = .ReleaseSmall,
    });
}
```

`uuid` should be unique for every application, and can be generated
with the `uuidgen` command.

`targetPlatforms` specifies the [Pebble
platforms](https://developer.repebble.com/guides/tools-and-resources/hardware-information/)
the watchface will be built for. In this case: `emery` (Pebble Time 2) and
`gabbro` (Pebble Round 2).

**Add Pebble application code to `src/main.zig`:**

```zig
// src/main.zig
const std = @import("std");

const pebble = @import("pebble");

var s_window: ?*pebble.Window = null;
var s_text_layer: ?*pebble.TextLayer = null;

fn window_load(window: ?*pebble.Window) callconv(.c) void {
    const window_layer = pebble.window_get_root_layer(window);
    const bounds = pebble.layer_get_bounds(window_layer);

    s_text_layer = pebble.text_layer_create(.{
        .origin = .{ .x = 0, .y = @divTrunc(bounds.size.h, 2) - 25 },
        .size = .{ .w = bounds.size.w, .h = 50 },
    });
    pebble.text_layer_set_font(s_text_layer, pebble.fonts_get_system_font(pebble.FONT_KEY_GOTHIC_28_BOLD));
    pebble.text_layer_set_text_color(s_text_layer, pebble.GColorBlue);
    pebble.text_layer_set_text_alignment(s_text_layer, pebble.GTextAlignmentCenter);
    pebble.text_layer_set_text(s_text_layer, "Hello World!");

    pebble.layer_add_child(window_layer, pebble.text_layer_get_layer(s_text_layer));
}

fn window_unload(_: ?*pebble.Window) callconv(.c) void {
    pebble.text_layer_destroy(s_text_layer);
}

fn init() void {
    s_window = pebble.window_create();
    pebble.window_set_window_handlers(s_window, .{
        .load = window_load,
        .unload = window_unload,
    });
    pebble.window_stack_push(s_window, true);
}

fn deinit() void {
    pebble.window_destroy(s_window);
}

export fn main() void {
    init();
    pebble.app_event_loop();
    deinit();
}
```

**Build the Pebble application:**

```
$ zig build
```

The `ld.lld: warning: address (0x82) of section .note.gnu.build-id is not a
multiple of alignment (4)` warning can be safely ignored.

The resulting `zig-out/watchface_example.pbw` can be installed to a Pebble
watch or published to the or [Pebble](https://appstore-api.repebble.com/dashboard) or [Rebble](https://developer.rebble.io/guides/appstore-publishing/) app store.

**Emulate the Pebble application:**

```
$ PEBBLE_EMULATOR=emery zig build upload
```

<table>
<tr>
<td>

![Screenshot Emery](screenshot.emery.png)

</td>
</tr>
</table>

```
$ PEBBLE_EMULATOR=gabbro zig build upload
```

<table>
<tr>
<td>

![Screenshot Gabbro](screenshot.gabbro.png)

</td>
</tr>
</table>

**Install the Pebble application to a watch:**

```
$ PEBBLE_PHONE=<phone ip> zig build upload
```

## Pebble C API

zig-pebble-sdk injects the [Pebble C API](https://developer.repebble.com/docs/c/)
into applications as an import under the name `pebble`.

```zig
const pebble = @import("pebble");

// Call any Pebble C API and look up constants under pebble:
//  pebble.window_create()
//  pebble.fonts_get_system_font(pebble.FONT_KEY_GOTHIC_28_BOLD)
// etc.
```

The translated Pebble C API can be inspected in the Zig cache with: `less $(find .zig-cache -name "pebble.zig")`

## Pebble App Metadata

The `.pebble` substructure in the options of
`pebble_sdk.addPebbleApplication()` mirrors the JSON [Pebble App
Metadata](https://developer.repebble.com/guides/tools-and-resources/app-metadata/).
See its [definition](build.zig#L447-L466) for an exhaustive list of options.

The `uuid` field should be unique for every application, and can be generated
with the `uuidgen` command.

Resources defined in the app metadata must be placed in a `resources/`
subdirectory, as with Pebble C apps. See the included [example](example/) for
an example project that uses an image resource.

zig-pebble-sdk code generates the IDs for message keys, resources, and
published media and injects it into applications as an import under the name
`pebble_appids`. This module exports `MESSAGE_KEYS`, `RESOURCE_IDS`, and
`PUBLISHED_IDS`, which are `enum(u32)` types containing the mapping of names to
IDs. For example, the ID of a resource named `IMAGE_FISH` can be looked up with
`@import("pebble_appids").RESOURCE_IDS.IMAGE_FISH`.

As a convenience, generated application IDs are available at
`zig-out/<platform>/<name>_appids.gen.zig` after building.

## Important Notes

* `GRect(x, y, w, h)`, and similar convenience macros that share the name of
  their underlying type, are not available and instead must be explicitly
  specified as `.{ .origin = .{ .x = <x>, .y = <y> }, .size = .{ .w = <w>, .h =
  <h> }}`.

* Zig does not currently support translating bitfields in C header files, so
  for certain Pebble C API types, only aggregate 8-bit types are available in
  place of their bitfield components:
    * `GColor` type lacks `b`, `g`, `r`, `a,` fields, and only has the 8-bit
      `argb` field.
    * `HealthMinuteData` lacks `is_invalid`, `light`, `padding` fields, and
      instead has an 8-bit `is_invalid_and_light_level` field.

* Optimization mode `.Debug` generates code that exceeds the allowed Pebble
  application binary size. The currently supported optimization modes are
  `.ReleaseSafe`, `.ReleaseFast`, `.ReleaseSmall`.

* Callbacks to Zig functions must use the `callconv(.c)` specifier to generate
  C ABI compatible callback sites:

```zig
fn tick_handler(tick_time: ?*pebble.tm, units_changed: pebble.TimeUnits) callconv(.c) void {
    ...
}
...
pebble.tick_timer_service_subscribe(pebble.MINUTE_UNIT, tick_handler);
```

* Dictionary Tuple values can be accessed through dereference and the
  code-generated `value()` getter:

```zig
const weather_temperature_tuple = pebble.dict_find(iterator, @intFromEnum(pebble_appids.MESSAGE_KEYS.WEATHER_TEMPERATURE)));
const temperature: ?i32 = if (weather_temperature_tuple) |t| t.*.value().*.int32 else null;
```

* Entry point `main()` must be exported: `export fn main() void { ... }`

## License

zig-pebble-sdk is MIT licensed. See the included [LICENSE](LICENSE) file.

Pebble SDK code is subject to its own license.
