* v1.4.2 - 09/15/2026
    * Improve error message when pebble header is not found in the Pebble SDK
      path.
    * Contributors
        * Aurélien Cibrario (@Yinameah) - 1ac372b

* v1.4.1 - 07/09/2026
    * Fix fault caused by Global Offset Table (GOT) section placement
      overlapping with the heap.
    * Contributors
        * Aaron Choo (@AaronCQL) - 2840c3e

* v1.4.0 - 06/23/2026
    * Migrate to Zig 0.16.
    * Fix `TouchEvent` structure translation in Pebble header.
    * Contributors
        * Treelar (@ninjawarrior1337) - d61749a

* v1.3.0 - 05/08/2026
    * Remove bundling, but keep packaging, of PebbleKit JS sources.
        * JavaScript build flow will be provided by the user.

* v1.2.0 - 04/14/2026
    * Add bundling and packaging of PebbleKit JS sources.

* v1.1.1 - 04/02/2026
    * Fix fault on Dictionary Tuple value access.
    * Fix missing toolchain bin path in inject_metadata_step build step.
    * Contributors
        * Mitchell (@mgerb) - 8382797

* v1.1.0 - 03/25/2026
    * Add font generation for font resources.
    * Forward optional command-line positional arguments in `upload` step.

* v1.0.0 - 03/20/2026
    * Initial release.
