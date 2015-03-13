'use strict'
{Disposable, CompositeDisposable} = require 'atom'

class BlockCursor
  primarySelector = 'atom-text-editor::shadow .cursors .cursor'
  secondarySelector = 'atom-text-editor::shadow .cursors.blink-off .cursor'
  cursorTypeMap =
    '\u25AE - Block': 'block' # ▮
    '\u25AF - Bordered box': 'bordered-box' # ▯
    '| - I-beam': 'i-beam'
    '_ - Underline': 'underline'

  config:
    cursorType:
      type: 'string'
      default: '\u25AE - Block'
      enum: (key for own key of cursorTypeMap)
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

  activate: ->
    @subs = new CompositeDisposable()
    @subs.add [
      atom.config.observe 'block-cursor.cursorType', @applyCursorType
      atom.config.observe 'block-cursor.primaryColor', @applyPrimaryColor
      atom.config.observe 'block-cursor.primaryColorAlpha', @applyPrimaryColor
      atom.config.observe 'block-cursor.secondaryColor', @applySecondaryColor
      atom.config.observe 'block-cursor.secondaryColorAlpha', @applySecondaryColor
      atom.config.observe 'block-cursor.blinkInterval', @applyBlinkInterval.bind @
      atom.config.observe 'block-cursor.pulseDuration', @applyPulseDuration
      atom.config.observe 'block-cursor.cursorThickness', @applyCursorThickness
      atom.config.observe 'block-cursor.cursorLineFix', @applyCursorLineFix
    ]
    # set some text in the preview field
    atom.config.set 'block-cursor.preview', 'The quick brown fox jumps over the lazy dog'
    # renamed to 'preview', so leave this here for few versions. preview was zzzpreview
    # as a hack to force it to show at the bottom of the list in the settings view
    atom.config.unset 'block-cursor.zzzpreview'

  deactivate: ->
    @subs.dispose()

  getColor: (which) ->
    color = atom.config.get "block-cursor.#{which}Color"
    color.alpha = atom.config.get "block-cursor.#{which}ColorAlpha"
    color.toRGBAString()

  getBlinkInterval: ->
    atom.config.get 'block-cursor.blinkInterval'

  applyCursorType: (cursorTypeName) ->
    cursorType = cursorTypeMap[cursorTypeName] ? cursorTypeName
    workspaceView = atom.views.getView atom.workspace
    workspaceView.className = workspaceView.className.replace /block-cursor-(?:block|bordered-box|i-beam|underline)/, ''
    workspaceView.classList.add "block-cursor-#{cursorType}"

  applyPrimaryColor: =>
    color = @getColor 'primary'
    @updateStylesheet primarySelector, 'background-color', color
    @updateStylesheet primarySelector, 'border-color', color
    # also apply to blink-off state if cursor blink is disabled
    if 0 is @getBlinkInterval()
      @updateStylesheet secondarySelector, 'background-color', color
      @updateStylesheet secondarySelector, 'border-color', color

  applySecondaryColor: =>
    # use primaryColor if cursor blink is disabled
    color = @getColor (if 0 is @getBlinkInterval() then 'primary' else 'secondary')
    @updateStylesheet secondarySelector, 'background-color', color
    @updateStylesheet secondarySelector, 'border-color', color

  applyBlinkInterval: do ->
    sub = null
    (interval) ->
      # max value for setInterval
      if interval is 0 then interval = -1 + Math.pow 2, 31
      @applySecondaryColor()
      sub?.dispose()
      sub = atom.workspace.observeTextEditors (editor) ->
        setTimeout ->
          editorPresenter = atom.views.getView(editor).component.presenter
          editorPresenter.stopBlinkingCursors true
          editorPresenter.cursorBlinkPeriod = interval
          editorPresenter.startBlinkingCursors()
        , 0
      @subs.add sub

  applyPulseDuration: (duration) =>
    @updateStylesheet primarySelector, 'transition-duration', "#{duration}ms"

  applyCursorThickness: (thickness) =>
    @updateStylesheet primarySelector, 'border-width', "#{thickness}px"

  applyCursorLineFix: (doFix) ->
    workspaceView = atom.views.getView atom.workspace
    workspaceView.classList[if doFix then 'add' else 'remove'] 'block-cursor-cursor-line-fix'

  updateStylesheet: do ->
    sub = null
    style = null

    (selector, property, value) ->
      unless sub?
        sub = new Disposable ->
          style.parentNode.removeChild style
          style = null
          sub = null
        @subs.add sub
      unless style?
        style = document.createElement 'style'
        style.type = 'text/css'
        document.querySelector('head atom-styles').appendChild style
      style.sheet.insertRule "#{selector} { #{property}: #{value}; }", style.sheet.cssRules.length

module.exports = new BlockCursor()
