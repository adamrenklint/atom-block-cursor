# block-cursor

![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-block.png)

Fancy cursor customisation.

## config

Version 0.13.0 breaks the config from previous versions, but has much more flexibility.

Multiple cursor types can be registered in `config.cson`. The `block-cursor:new-custom-cursor` command can register a new cursor type.

The following properties can be set for each cursor type:

```coffee
selector: 'atom-text-editor'
scopes: [ '*' ]
blinkOn:
  backgroundColor: '#393939'
  borderStyle: 'none'
  borderColor: 'transparent'
  borderWidth: 0
blinkOff:
  backgroundColor: 'transparent'
  borderStyle: 'none'
  borderColor: 'transparent'
  borderWidth: 0
pulseDuration: 0
cursorLineFix: false
```

### selector

Defines which `atom-text-editor` elements the cursor type should apply to. The selector should select an `atom-text-editor` element.

### scopes

List of scopes that the cursor type should apply to.

### blinkOn.backgroundColor & blinkOff.backgroundColor

The background color of the cursor in blink-on or blink-off state.

### blinkOn.borderStyle & blinkOff.borderStyle

The border style of the cursor in blink-on or blink-off state. Can be one of the following:

* `bordered-box` <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-bordered-box.png)
* `i-beam` <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-i-beam.png)
* `underline` <br>![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-underline.png)
* `none`

### blinkOn.borderColor & blinkOff.borderColor

The border color of the cursor in blink-on or blink-off state.

### blinkOn.borderWidth & blinkOff.borderWidth

The border width of the cursor in blink-on or blink-off state.

### pulseDuration

Pulse effect that fades the cursor from blink-on to blink-off state (instead of blinking). Set to 0 to disable.

![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-pulse.gif)

### cursorLineFix

When your syntax theme uses a `background-color` on `.cursor-line` - the line the cursor is on - the `block` cursor may become invisible. This is because the cursor has a `z-index` of `-1`, to make it render behind the text instead of above it. This fix sets the cursor's `z-index` to `1`, to make it render above the text, so you should use low `alpha` values for `primaryColor` and `secondaryColor` if you enable this fix.

The `cursorLineFix` is currently ignored due to the new tile rendering of the editor that was introduced in Atom v0.209.0. It will always be set to `true`, to allow the cursor to render above the text, so make sure the background colors you use have low alpha values. Otherwise the character under the cursor will not be visible.

You can also add this to your `styles.less` to disable the line highlight:
```less
atom-text-editor::shadow .lines .line.cursor-line {
  background-color: transparent;
}
```



### example config

```coffee
  "block-cursor":
    # white cursor by default
    global:
      blinkOn:
        backgroundColor: "white"
    # dary grey cursor on [mini] editors
    mini:
      selector: "atom-text-editor[mini]"
      blinkOn:
        backgroundColor: "darkgrey"
    # box cursor when editor is not focused
    "no-focus":
      selector: "atom-text-editor:not(.is-focused)"
      blinkOn:
        backgroundColor: "transparent"
        borderColor: "white"
        borderStyle: "bordered-box"
        borderWidth: 1
    # red cursor in coffeescript
    "coffee-script":
      scopes: [ ".source.coffee" ],
      blinkOn:
        backgroundColor: "red"
```



### HELP! the blink interval setting has disappeared

Use the [cursor-blink-interval](https://atom.io/packages/cursor-blink-interval) package instead. Due to the changes in v0.13.0 it was not as easy to implement it alongside the other features.



## commands

### `block-cursor:new-custom-cursor`

This command adds a new cursor type that can be customised customise to `config.cson`, that can be configured from the settings view. By default it will be called `custom-X`, but it can be renamed to anything you like.



## scoped config

From `v0.13.0` scoped config is done by creating a new cursor type. See the example config.



## known issues

Due to a [bug](https://github.com/atom/settings-view/issues/518) in [settings-view](https://atom.io/packages/settings-view) sometimes the settings don't appear in the settings view. In that case you'll have to update `~/.atom/config.cson` by hand.



## contribute

Have other neat ideas for cursor customization? Found a bug?

1. Fork the repo
2. :rocket: Make awesome things happen
3. Create a pull request

Or [create a new issue](https://github.com/olmokramer/atom-block-cursor/issues/new) at the repository if you can't do it yourself.

## copyright & license

&copy; 2015 Olmo Kramer <br> [MIT license](LICENSE.md)
