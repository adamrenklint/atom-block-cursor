![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/block-cursor.png)

## Configure

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

![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-bordered-box.png)

![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-i-beam.png)

![Block cursor](https://raw.githubusercontent.com/olmokramer/atom-block-cursor/master/cursor-underline.png)

`none`

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
atom-text-editor.editor .lines .line.cursor-line {
  background-color: transparent;
}
```



### Example config

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
    # lightgray cursor when using the one-dark-syntax theme
    "one-dark-syntax":
      selector: ".theme-one-dark-syntax atom-text-editor"
      blinkOn:
        backgroundColor: "lightgray"
    # darkgray cursor when using the one-light-syntax theme
    "one-light-syntax":
      selector: ".theme-one-light-syntax atom-text-editor"
      blinkOn:
        backgroundColor: "darkgray"
```



## Commands

### `block-cursor:new-custom-cursor`

This command adds a new cursor type that can be customised customise to `config.cson`, that can be configured from the settings view. By default it will be called `custom-X`, but it can be renamed to anything you like.


## Contribute

Have other neat ideas for cursor customization? Found a bug?

1. :fork_and_knife: Fork the repo
2. :rocket: Make awesome things happen
3. :octocat: Create a pull request

Or [create a new issue](https://github.com/adamrenklint/atom-block-cursor/issues/new) at the repository if you can't do it yourself.

## License and credits

&copy; 2015 Olmo Kramer<br/>
Maintainer: [Adam Renklint](http://adamrenklint.com)<br/>
[MIT license](LICENSE.md)
