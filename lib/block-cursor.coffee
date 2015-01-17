class BlockCursor
  cursorStyle = null
  primarySelector = 'atom-text-editor::shadow .cursors .cursor'
  secondarySelector = 'atom-text-editor::shadow .cursors.blink-off .cursor'

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

  applyCursorType: (@cursorType) ->
    workspaceView = atom.views.getView atom.workspace
    workspaceView.className = workspaceView.className.replace /block-cursor-(block|bordered-box|i-beam|underline)/, ''
    workspaceView.classList.add "block-cursor-#{cursorType}"
    @applyPrimaryColor()
    @applySecondaryColor()

  applyPrimaryColor: (color) ->
    color ?= atom.config.get 'block-cursor.primaryColor'
    property = switch @cursorType
      when 'block' then 'background-color'
      else 'border-color'
    value = color.toRGBAString()
    @updateStylesheet primarySelector, property, value

  applySecondaryColor: (color) ->
    color ?= atom.config.get 'block-cursor.secondaryColor'
    property = switch @cursorType
      when 'block' then 'background-color'
      else 'border-color'
    value = color.toRGBAString()
    @updateStylesheet secondarySelector, property, value

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

module.exports = new BlockCursor()
