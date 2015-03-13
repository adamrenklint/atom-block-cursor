# block-cursor <small><small>[github.com](https://github.com/olmokramer/atom-block-cursor) [atom.io](https://atom.io/packages/block-cursor)</small></small>

![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-block.png)

What started out as a simple package to replace the I-beam cursor for a Block cursor, ended up a complete cursor customization package.

### cursor type

The cursor can be one of the following:
* Block <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-block.png)
* Bordered-box <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-bordered-box.png)
* I-beam <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-i-beam.png)
* Underline <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-underline.png)

### primary & secondary cursor color and their alpha channels

The primary and secondary colors determine the color of the cursor in it's `blink-on` and `blink-off` state, respectively.

Because Chrome's color picker on Linux doesn't support the alpha channel, there's also a separate config for the alpha channel. Updating the alpha from the color picker also updates that config, and vice-versa.

### blink interval

The blinking interval of the cursor. Set to `0` to disable cursor blinking.

### pulse duration

A pulse effect that fades the cursor from `primaryColor` to `secondaryColor`. Set to 0 to disable.

![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-pulse.gif)

### cursor thickness

The thickness of the non-block cursors.

### cursor line fix

When your syntax theme uses a `background-color` on `.cursor-line` - the line the cursor is on - the `block` cursor may become invisible. This is because the cursor has a `z-index` of `-1`, to make it render behind the text instead of above it. This fix sets the cursor's `z-index` to `1`, to make it render above the text, so you should use low `alpha` values for `primaryColor` and `secondaryColor` if you enable this fix.

## known issues

* Blink interval doesn't work in `mini` editors - the single line input fields, for example in settings - except for disabling blink.

## contribute

Have other neat ideas for cursor customization? Found a bug?

1. Fork the repo
2. :rocket: Make awesome things happen
3. Create a pull request

Or [create a new issue](https://github.com/olmokramer/atom-block-cursor/issues/new) at the repository if you can't do it yourself.

## copyright & license

&copy; 2015 Olmo Kramer under [LICENSE.md](MIT license).