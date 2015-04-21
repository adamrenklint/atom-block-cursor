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
    type: 'color'
    default: '#393939'
    order: 1

  primaryColorAlpha:
    description: '0 means invisible, 1 means fully opaque.'
    type: 'number'
    default: 1
    minimum: 0
    maximum: 1
    order: 2

  secondaryColor:
    type: 'color'
    default: 'transparent'
    order: 3

  secondaryColorAlpha:
    description: '0 means invisible, 1 means fully opaque.'
    type: 'number'
    default: 0
    minimum: 0
    maximum: 1
    order: 4

  blinkInterval:
    description: 'Set to 0 to disable cursor blinking.'
    type: 'integer'
    default: 800
    minimum: 0
    order: 5

  pulseDuration:
    description: 'Set to 0 to disable pulse effect.'
    type: 'integer'
    default: 0
    minimum: 0
    order: 6

  cursorThickness:
    description: 'Doesn\'t apply to "block" cursor type.'
    type: 'integer'
    default: 1
    minimum: 1
    order: 7

  useHardwareAcceleration:
    description: 'Use hardware accelerated transitions for the pulse duration when secondaryColorAlpha is set to 0'
    type: 'boolean'
    default: true
    order: 8

  preview:
    description: 'This field does nothing, it\'s just here to preview your cursor. The blinkInterval setting does not work in this field.'
    type: 'string'
    default: ''
    order: 9

  cursorLineFix:
    description: 'Fix to render the cursor above the text when the cursor line has a background-color. See readme for more info.'
    type: 'boolean'
    default: false
    order: 10