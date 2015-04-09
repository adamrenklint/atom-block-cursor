module.exports =
  cursorType:
    type: 'string'
    default: 'block'
    enum: [
      'block'
      'bordered-box'
      'i-beam'
      'underline'
    ]
    order: 0

  primaryColor:
    description: 'Primary color of the cursor.'
    type: 'color'
    default: '#393939'
    order: 1

  primaryColorAlpha:
    description: 'Alpha of the primary color. 0 means invisible, 1 means fully opaque.'
    type: 'number'
    default: 1
    minimum: 0
    maximum: 1
    order: 2

  secondaryColor:
    description: 'Secondary color of the cursor.'
    type: 'color'
    default: 'transparent'
    order: 3

  secondaryColorAlpha:
    description: 'Alpha of the secondary color. 0 means invisible, 1 means fully opaque.'
    type: 'number'
    default: 0
    minimum: 0
    maximum: 1
    order: 4

  blinkInterval:
    description: 'Cursor blinking interval in milliseconds. Set to 0 to disable cursor blinking.'
    type: 'integer'
    default: 800
    minimum: 0
    order: 5

  pulseDuration:
    description: 'Duration of the pulse transition in millisecond. Set to 0 to disable.'
    type: 'integer'
    default: 0
    minimum: 0
    order: 6

  cursorThickness:
    description: 'Thickness of the cursor in pixels. Doesn\'t apply to "block" cursor type.'
    type: 'integer'
    default: 1
    minimum: 1
    order: 7

  preview:
    description: 'This field does nothing, it\'s just here to preview your cursor. The blinkInterval setting does not work in this field.'
    type: 'string'
    default: ''
    order: 8

  cursorLineFix:
    description: 'Fix to render the cursor above the text when the cursor line has a background-color. See readme for more info.'
    type: 'boolean'
    default: false
    order: 9