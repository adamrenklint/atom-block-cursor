'use strict'
{Disposable, CompositeDisposable} = require 'atom'
_ = require 'underscore'

class BlockCursor
  config:
    cursorType:
      type: 'string'
      default: '\u25AE - Block'
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

  activate: ->
    @subs = new CompositeDisposable()
    @subs.add atom.config.observe 'block-cursor', (config) =>
      @update config
    # set some text in the preview field
    atom.config.set 'block-cursor.preview', 'The quick brown fox jumps over the lazy dog'

  deactivate: ->
    @subs.dispose()

  update: do ->
    subs = null
    cache = {}
    (config) ->
      subs?.dispose()
      subs = new CompositeDisposable()
      @updateGlobalConfig _.clone(config)
      subs.add atom.workspace.observeTextEditors (editor) =>
        scope = editor.getGrammar().scopeName
        sub = atom.config.observe 'block-cursor', scope: [scope], (scopedConfig) =>
          @updateEditorConfig editor, scope.split('.'), _.clone(config), scopedConfig
        subs.add editor.onDidDestroy ->
          sub.dispose()
        subs.add sub
      @subs.add subs

  updateGlobalConfig: (config) ->
    config.editor = atom.workspace
    @applyCursorType config
    @applyPrimaryColor config
    @applySecondaryColor config
    @applyPulseDuration config
    @applyCursorThickness config
    @applyCursorLineFix config

  updateEditorConfig: (editor, grammar, config, scopedConfig) ->
    for own key, value of scopedConfig
      config[key] = value
    config.editor = editor
    config.grammar = grammar
    @applyCursorType config
    @applyPrimaryColor config
    @applySecondaryColor config
    @applyBlinkInterval config
    @applyPulseDuration config
    @applyCursorThickness config
    @applyCursorLineFix config

  applyCursorType: (config) ->
    {editor, cursorType} = config
    editorView = atom.views.getView editor
    editorView.className = editorView.className.replace /block-cursor-(block|bordered-box|i-beam|underline)/, ''
    editorView.classList.add "block-cursor-#{cursorType}"

  applyPrimaryColor: (config) =>
    {grammar, primaryColor, primaryColorAlpha, blinkInterval} = config
    primaryColor.alpha = primaryColorAlpha
    color = primaryColor.toRGBAString()
    primarySelector = @getPrimarySelectorForGrammar grammar
    @updateStylesheet primarySelector, 'background-color', color
    @updateStylesheet primarySelector, 'border-color', color
    # also apply to blink-off state if cursor blink is disabled
    if blinkInterval is 0
      secondarySelector = @getSecondarySelectorForGrammar grammar
      @updateStylesheet secondarySelector, 'background-color', color
      @updateStylesheet secondarySelector, 'border-color', color

  applySecondaryColor: (config) =>
    {grammar, secondaryColor, secondaryColorAlpha, blinkInterval} = config
    # use primaryColor if cursor blink is disabled
    return if blinkInterval is 0
    secondaryColor.alpha = secondaryColorAlpha
    color = secondaryColor.toRGBAString()
    secondarySelector = @getSecondarySelectorForGrammar grammar
    @updateStylesheet secondarySelector, 'background-color', color
    @updateStylesheet secondarySelector, 'border-color', color

  applyBlinkInterval: (config) ->
    {editor, blinkInterval} = config
    if blinkInterval is 0
      blinkInterval = -1 + Math.pow 2, 31
    process.nextTick ->
      editorPresenter = atom.views.getView(editor).component.presenter
      editorPresenter.stopBlinkingCursors true
      editorPresenter.cursorBlinkPeriod = blinkInterval
      editorPresenter.startBlinkingCursors()

  applyPulseDuration: (config) =>
    {grammar, pulseDuration} = config
    primarySelector = @getPrimarySelectorForGrammar grammar
    @updateStylesheet primarySelector, 'transition-duration', "#{pulseDuration}ms"

  applyCursorThickness: (config) =>
    {grammar, cursorThickness} = config
    primarySelector = @getPrimarySelectorForGrammar grammar
    @updateStylesheet primarySelector, 'border-width', "#{cursorThickness}px"

  applyCursorLineFix: (config) ->
    {editor, cursorLineFix} = config
    editorView = atom.views.getView editor
    if cursorLineFix
      editorView.classList.add 'block-cursor-line-fix'
    else
      editorView.classList.remove 'block-cursor-line-fix'

  getPrimarySelectorForGrammar: (grammar = []) ->
    str = ''
    for identifier in grammar
      str += "[data-grammar~=\"#{identifier}\"]"
    "atom-text-editor#{str}::shadow .cursors .cursor"

  getSecondarySelectorForGrammar: (grammar = []) ->
    str = ''
    for identifier in grammar
      str += "[data-grammar~=\"#{identifier}\"]"
    "atom-text-editor#{str}::shadow .cursors.blink-off .cursor"

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
