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
* Replaced the 'enablePulse' option with 'pulseDuration' option

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
* Removed 'cursorBlink' option
* Renamed 'cursorColor' option -> 'primaryColor'
* Added 'secondaryColor' option

## 0.2.4 - Specs
* Created specs for testing

## 0.2.3 - !important stuff
* Made compatible with certain syntax themes that set !important on the border color of the cursor

## 0.2.2 - Grammar nazi
* Fixed capitalization in config descriptions

## 0.2.1 - Blinking cursors
* Fixed the 'cursorBlink' config option

## 0.2.0 - Config color
* Using new 'color' type for the cursorColor option

## 0.1.1 - Readme fix
* Fixed the image's url in the readme

## 0.1.0 - First Release
* Every feature added
