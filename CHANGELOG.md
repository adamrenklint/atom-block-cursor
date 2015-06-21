# block-cursor changelog

## 0.13.1
* Fix #23

## 0.13.0
* Rewrite. Breaks current configuration. See [README.md](README.md).
* Disable `cursorLineFix` setting temporarily, because of a conflict with tile rendering introduced in Atom v0.209.0.

## 0.12.5
* Fix bug where cursor blinking wasn't disabled properly
* Add specs

## 0.12.4
* Fix #14

## 0.12.3
* Merge #12

## 0.12.2
* Fix #11 by adding `useHardwareAcceleration` setting

## 0.12.1
* Animate opacity when `secondaryColorAlpha` is `0`. Fixes #9
* Fix #10

## 0.12.0
* Rewrite
* Separate scoped config observation into its own npm package

## 0.11.2
* Fix #8

## 0.11.1
* Fix some minor issues

## 0.11.0
* Add support for scoped config

## 0.10.1
* Fix readme
* Some rewriting

## 0.10.0
* Add separate alpha channel configs for both the color configs because the color picker on Linux doesn't support them.
* Add fix for syntax themes with a `background-color` on the `.cursor-line`
* Some rewriting

## 0.9.9
* Fix #6

## 0.9.8
* Don't set secondaryColor when changing blinkInterval

## 0.9.7
* Better fix for #5

## 0.9.6
* Fix #5

## 0.9.5
* Fix cursor blink
* Remove underscore dependency

## 0.9.4
* Fix `blinkInterval` config description

## 0.9.3
* Updated readme's `blink interval` section
* Set default value for the `preview` field, to avoid a warning at activation
* Workaround for disabling cursor blinking in `mini` editors

## 0.9.2
* Fixed issue where package deactivation sometimes throws an exception

## 0.9.1
* Changed `blinkInterval`'s default from 500 to 400 to match Atom's default behavior
* Dispose of editor subscription on package deactivation

## 0.9.0
* Added `blinkInterval` option
* Removed `pulseDuration` maximum

## 0.8.1
* Added preview field to the package settings

## 0.8.0
* Added `cursorThickness` option

## 0.7.6
* Use CompositeDisposable for the config subscriptions

## 0.7.5
* Fix: remove cursorStyle element from the dom on package deactivation

## 0.7.4
* Workaround for [#atom/5306](https://github.com/atom/atom/issues/5306)

## 0.7.3
* Created a map between `cursorType` names/values for clearer options in the settings view select box

## 0.7.2
* Show cursor examples in the settings view

## 0.7.1
* Write less rules to the stylesheet

## 0.7.0 - Modernizing
* Removed deprecated functions
  * atom.themes.removeStylesheet
  * atom.themes.requireStylesheet

## 0.6.1
* Nicer looking readme

## 0.6.0 - Cursor galore
* Added 3 types of cursors. See readme for images
  * I-beam
  * Bordered box
  * Underline

## 0.5.1
* Updated readme

## 0.5.0 - Fancy pulse
* Replaced the `enablePulse` option with `pulseDuration` option

## 0.4.6
* Fix: make block-cursor.coffee look for vars.less instead of colors.less
* Fix: make block-cursor.less look for vars.less instead of colors.less

## 0.4.5
* Removed the block-cursor class from the workspaceView
* Removed the block-cursor-pulse class from the workspaceView
* Renamed styles/includes/colors.less -> styles/includes/vars.less

## 0.4.4 - Cleanup
* Removed some console.logs

## 0.4.3 - Keeping track
* Fixed false changelog information

## 0.4.2 - Config stuff
* Changed the configuration mechanism, much easier to keep track of the config

## 0.4.1 - Cleanup
* Removed some stray console.logs

## 0.4.0
* Added pulse option

## 0.3.1 - Some fixes
* Force cursor opacity to 1, also in blink-off state
* Slightly changed the atom-text-editor[mini] selector

## 0.3.0 - Fancy blinking
* Removed `cursorBlink` option
* Renamed `cursorColor` option -> `primaryColor`
* Added `secondaryColor` option

## 0.2.4 - Specs
* Created specs for testing

## 0.2.3 - !important stuff
* Made compatible with certain syntax themes that set !important on the border color of the cursor

## 0.2.2 - Grammar nazi
* Fixed capitalization in config descriptions

## 0.2.1 - Blinking cursors
* Fixed the `cursorBlink` config option

## 0.2.0 - Config color
* Using new `color` type for the cursorColor option

## 0.1.1 - Readme fix
* Fixed the image's url in the readme

## 0.1.0 - First Release
* Every feature added
