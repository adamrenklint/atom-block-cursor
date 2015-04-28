module.exports =
  transparent:
    red: 0
    green: 0
    blue: 0
    alpha: 0
  primaryColor:
    red: 255
    green: 0
    blue: 0
    alpha: 1
  secondaryColor:
    red: 0
    green: 0
    blue: 255
    alpha: .5

  parseColor: (color) ->
    return color if typeof color isnt 'string'

    rgbaRegex = /rgba?\((\d{1,3}),\s(\d{1,3}),\s(\d{1,3})(?:,\s([\d.]+))?\)/
    [match, red, green, blue, alpha] = rgbaRegex.exec(color)

    red = parseInt red
    green = parseInt green
    blue = parseInt blue
    alpha = 1 / 10 * Math.round 10 * Number.parseFloat alpha
    alpha = 1 if Number.isNaN alpha

    {red, green, blue, alpha}

  colorEquals: (color, ref) ->
    if typeof color is 'string'
      color = @parseColor color
    if typeof ref is 'string'
      ref = @parseColor ref

    color.red is ref.red and
    color.green is ref.green and
    color.blue is ref.blue and
    color.alpha is ref.alpha