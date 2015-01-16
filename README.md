# block-cursor

![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-block.png)

What started out as a simple package to replace the I-beam cursor for a Block cursor, ended up getting more and more options. This package allows the cursor to be customized in a number of ways.

## config

#### cursor type

The cursor can be one of the following:
* Block <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-block.png)
* Bordered-box <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-bordered-box.png)
* I-beam <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-i-beam.png)
* Underline <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-underline.png)

#### primary cursor color & secondary cursor color

The primary and secondary colors determine the color of the cursor in it's `blink-on` and `blink-off` state, respectively. From the settings menu, you can't set transparency, so if you want transparency, that has to be done by editing the `~/.atom/config.cson` file directly. Consult [the docs](https://atom.io/docs/api/latest/Config) about color objects.

#### pulse duration

Set the pulse duration to let the cursor fade from `primary color` to `secondary color`, instead of the default blinking behavior.

![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-pulse.gif)

<small>Cursor blinking</small>

## copyright

Copyright 2015 Olmo Kramer under MIT license.