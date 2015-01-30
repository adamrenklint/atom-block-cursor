'use strict'
class BlockCursor
  cursorStyle = null
  cursorTypeMap =
    '\u25AE - Block': 'block'
    '\u25AF - Bordered box': 'bordered-box'
    '| - I-beam': 'i-beam'
    '_ - Underline': 'underline'
  primarySelector = 'atom-text-editor::shadow .cursors .cursor'
  secondarySelector = 'atom-text-editor::shadow .cursors.blink-off .cursor'

  config:
    cursorType:
      type: 'string'
      default: '\u25AE - Block'
      enum: (key for own key of cursorTypeMap)
    primaryColor:
      description: 'Primary color of the cursor'
      type: 'color'
      default: '#393939'
    secondaryColor:
      description: 'Secondary color of the cursor'
      type: 'color'
      default: '#393939'
    pulseDuration:
      description: 'Duration of the pulse transition in milliseconds, set to 0 to disable pulse'
      type: 'integer'
      default: 0
      minimum: 0
      maximum: 500

  activate: ->
    @cursorTypeObserveSubscription =
      atom.config.observe 'block-cursor.cursorType', (val) => @applyCursorType val
    @primaryColorObserveSubscription =
      atom.config.observe 'block-cursor.primaryColor', (val) => @applyPrimaryColor val
    @secondaryColorObserveSubscription =
      atom.config.observe 'block-cursor.secondaryColor', (val) => @applySecondaryColor val
    @pulseDurationObserveSubscription =
      atom.config.observe 'block-cursor.pulseDuration', (val) => @applyPulse val

  deactivate: ->
    @cursorTypeObserveSubscription.dispose()
    @primaryColorObserveSubscription.dispose()
    @secondaryColorObserveSubscription.dispose()
    @pulseDurationObserveSubscription.dispose()
    cursorStyle.parentNode.removeChild cursorStyle
    cursorStyle = null

  applyCursorType: (cursorTypeName) ->
    @cursorType = cursorType = cursorTypeMap[cursorTypeName]
    workspaceView = atom.views.getView atom.workspace
    workspaceView.className = workspaceView.className.replace /block-cursor-(block|bordered-box|i-beam|underline)/, ''
    workspaceView.classList.add "block-cursor-#{cursorType}"

  applyPrimaryColor: (color) ->
    unless color?.toRGBAString? then color = atom.config.get 'block-cursor.primaryColor'
    color = color.toRGBAString?() or @toRGBAString color
    @updateStylesheet primarySelector, 'background-color', color
    @updateStylesheet primarySelector, 'border-color', color

  applySecondaryColor: (color) ->
    unless color?.toRGBAString? then color = atom.config.get 'block-cursor.secondaryColor'
    color = color.toRGBAString?() or @toRGBAString color
    @updateStylesheet secondarySelector, 'background-color', color
    @updateStylesheet secondarySelector, 'border-color', color

  applyPulse: (duration) ->
    @updateStylesheet primarySelector, 'transition-duration', "#{duration}ms"

  getCursorStyle: ->
    return cursorStyle if cursorStyle?
    cursorStyle = document.createElement 'style'
    cursorStyle.type = 'text/css'
    document.querySelector('head atom-styles').appendChild cursorStyle
    cursorStyle

  updateStylesheet: (selector, property, value) ->
    sheet = @getCursorStyle().sheet
    sheet.insertRule "#{selector} { #{property}: #{value}; }", sheet.cssRules.length

  toRGBAString: (color) ->
    return color if typeof color is 'string' and color.match /#([0-9A-Fa-f]{3}){1,2}|rgba\(\d{1,3}(,\s?\d{1,3}){2},\s?(1|0?\.\d+)\)|rgb\(\d{1,3}(,\s?\d{1,3}\){2})/
    "rgba(#{color.red}, #{color.green}, #{color.blue}, #{color.alpha})"

module.exports = new BlockCursor()
