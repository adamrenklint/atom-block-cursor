'use strict'
{Disposable, CompositeDisposable} = require 'atom'
_ = require 'underscore'

class BlockCursor
  config:
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

  activate: ->
    atom.config.set 'block-cursor.preview', 'The quick brown fox jumps over the lazy dog'

    @disposables = new CompositeDisposable()

    @disposables.add atom.config.observe 'block-cursor', (@globalConfig) =>
      @updateCursorStyleForScope editors: [atom.workspace], scopeName: '*', @globalConfig
      for own scopeName, scopedConfigObserver of @scopedConfigObservers
        @updateCursorStyleForScope scopedConfigObserver, @configForScope scopeName

    @disposables.add atom.workspace.observeTextEditors (editor) =>
      @observeScopedConfigForEditor editor

    @disposables.add new Disposable =>
      for own scopeName, scopedConfigObserver of @scopedConfigObservers
        scopedConfigObserver.dispose()
      @scopedConfigObservers = {}

  deactivate: ->
    @disposables.dispose()

  scopedConfigObservers: {}

  configForScope: (scopeName) ->
    atom.config.get 'block-cursor', scope: [scopeName]

  observeScopedConfigForEditor: (editor) ->
    scopeName = editor.getGrammar().scopeName
    scopedConfigObserver = @observeScopedConfig scopeName, =>
      @scopedConfigObservers[scopeName] = null
    scopedConfigObserver.subscribe editor
    @disposables.add editor.onDidDestroy =>
      scopedConfigObserver.unsubscribe editor
      {editor, scopedConfigObserver} = {}
    @disposables.add scopedConfigObserver
    @updateCursorStyleForScope scopedConfigObserver, @configForScope scopeName

  observeScopedConfig: (scopeName, disposalAction) ->
    @scopedConfigObservers[scopeName] ?=
      scopeName: scopeName
      editors: []
      disposable: atom.config.onDidChange 'block-cursor', scope: [scopeName], (config) =>
        @updateCursorStyleForScope @scopedConfigObservers[scopeName], config.newValue
      dispose: ->
        disposalAction()
        @disposable.dispose()
        {@editors, @disposable} = {}
      subscribe: (editor) ->
        @editors.push editor
      unsubscribe: (editor) ->
        @editors = _.without @editors, editor
        @dispose() if @editors.length is 0

  updateCursorStyleForScope: ({scopeName, editors}, config) ->
    config = @parseConfig config
    {colorProperty, primaryColor, secondaryColor, pulseDuration, cursorThickness} = config
    process.nextTick =>
      @updateStylesheet scopeName, colorProperty, primaryColor
      @updateStylesheet scopeName, colorProperty, secondaryColor, true
      @updateStylesheet scopeName, 'transition-duration', "#{pulseDuration}ms"
      @updateStylesheet scopeName, 'border-width', "#{cursorThickness}px"
      for editor in editors
        @updateCursorStyleForEditor editor, config

  updateCursorStyleForEditor: (editor, {cursorType, blinkInterval, cursorLineFix}) ->
    editorView = atom.views.getView editor
    editorView.classList.remove 'cursor-block', 'cursor-bordered-box', 'cursor-i-beam', 'cursor-underline'
    editorView.classList.add "cursor-#{cursorType}"
    if editorView.component?.presenter?
      editorPresenter = editorView.component.presenter
      editorPresenter.stopBlinkingCursors true
      editorPresenter.cursorBlinkPeriod = blinkInterval
      editorPresenter.startBlinkingCursors()
    if cursorLineFix
      editorView.classList.add 'cursor-line-fix'
    else
      editorView.classList.remove 'cursor-line-fix'

  parseConfig: (config) ->
    config = _.defaults {}, config, @globalConfig
    {cursorType, primaryColor, primaryColorAlpha, secondaryColor, secondaryColorAlpha, blinkInterval} = config
    config.primaryColor = @parseColor primaryColor, primaryColorAlpha
    if blinkInterval is 0
      config.secondaryColor = primaryColor
      config.blinkInterval = -1 + Math.pow 2, 31
    else
      config.secondaryColor = @parseColor secondaryColor, secondaryColorAlpha
    config.colorProperty = switch cursorType
      when 'block' then 'background-color'
      else 'border-color'
    config

  parseColor: (color, alpha) ->
    newColor =
      red: color.red
      green: color.green
      blue: color.blue
      alpha: alpha
    color.toRGBAString.call newColor

  updateStylesheet: do ->
    {sub, style} = {}

    selectorForScope = (scopeName, isBlinkOff) ->
      selector = 'atom-text-editor'
      unless scopeName is '*'
        for identifier in scopeName.split('.')
          selector += "[data-grammar~=\"#{identifier}\"]"
      selector += '::shadow .cursors'
      if isBlinkOff
        selector += '.blink-off'
      selector += ' .cursor'

    (scopeName, property, value, isBlinkOff = false) ->
      unless sub?
        sub = new Disposable ->
          style.parentNode.removeChild style
          {style, sub} = {}
        @disposables.add sub
      unless style?
        style = document.createElement 'style'
        style.type = 'text/css'
        document.querySelector('head atom-styles').appendChild style
      selector = selectorForScope scopeName, isBlinkOff
      style.sheet.insertRule "#{selector} { #{property}: #{value}; }", style.sheet.cssRules.length

module.exports = new BlockCursor()
