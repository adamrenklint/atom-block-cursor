class BlockCursor
  colorStyleElement = null
  primarySelector = '.block-cursor atom-text-editor::shadow .cursors .cursor'
  secondarySelector = '.block-cursor atom-text-editor::shadow .cursors.blink-off .cursor'

  config:
    primaryColor:
      description: 'Primary color of the cursor'
      type: 'color'
      default: '#393939'
    secondaryColor:
      description: 'Secondary color of the cursor'
      type: 'color'
      default: '#393939'
    enablePulse:
      description: 'Fade from primary color to secondary color'
      type: 'boolean'
      default: false

  activate: ->
    workspaceView = atom.views.getView atom.workspace
    workspaceView.classList.add 'block-cursor'

    @primaryColorObserveSubscription =
      atom.config.observe 'block-cursor.primaryColor', (val) => @applyPrimaryColor val
    @secondaryColorObserveSubscription =
      atom.config.observe 'block-cursor.secondaryColor', (val) => @applySecondaryColor val
    @enablePulseObserveSubscription =
      atom.config.observe 'block-cursor.enablePulse', (val) => @applyPulse val

  deactivate: ->
    workspaceView = atom.views.getView atom.workspace
    workspaceView.classList.remove 'block-cursor'
    workspaceView.classList.remove 'block-cursor-pulse'

    @primaryColorObserveSubscription.dispose()
    @secondaryColorObserveSubscription.dispose()

  getColorStyleElement: ->
    return colorStyleElement if colorStyleElement?
    colorStyleElement = document.createElement 'style'
    colorStyleElement.type = 'text/css'
    document.querySelector('head atom-styles').appendChild colorStyleElement
    colorStyleElement.sheet.insertRule "#{primarySelector} {}", 0
    colorStyleElement.sheet.insertRule "#{secondarySelector} {}", 1
    return colorStyleElement

  applyPrimaryColor: (color) ->
    stylesheet = @getColorStyleElement().sheet
    stylesheet.deleteRule 0
    stylesheet.insertRule "#{primarySelector} { background-color: #{color.toRGBAString()}; }", 0

  applySecondaryColor: (color) ->
    stylesheet = @getColorStyleElement().sheet
    stylesheet.deleteRule 1
    stylesheet.insertRule "#{secondarySelector} { background-color: #{color.toRGBAString()}; }", 1

  applyPulse: (enabled) ->
    workspaceView = atom.views.getView atom.workspace
    if enabled
      workspaceView.classList.add 'block-cursor-pulse'
    else
      workspaceView.classList.remove 'block-cursor-pulse'

module.exports = new BlockCursor()