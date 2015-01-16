fs = require 'fs'
path = require 'path'

class BlockCursor
  mainLessFile: path.join __dirname, '..', 'styles', 'block-cursor.less'
  colorsLessFile: path.join __dirname, '..', 'styles', 'includes', 'colors.less'

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
    @enablePulseObserveSubscription.dispose()

  applyPrimaryColor: (primaryColor) ->
    secondaryColor = atom.config.get 'block-cursor.secondaryColor'
    @writeLessVariables primaryColor, secondaryColor

  applySecondaryColor: (secondaryColor) ->
    primaryColor = atom.config.get 'block-cursor.primaryColor'
    @writeLessVariables primaryColor, secondaryColor

  writeLessVariables: (primaryColor, secondaryColor) ->
    text = """
      @block-cursor-primary-color: #{primaryColor.toRGBAString()};
      @block-cursor-secondary-color: #{secondaryColor.toRGBAString()};
    """
    fs.writeFileSync @colorsLessFile, text
    @reloadStylesheet()

  reloadStylesheet: ->
    atom.themes.removeStylesheet @mainLessFile
    atom.themes.requireStylesheet @mainLessFile

  applyPulse: (enabled) ->
    console.log enabled
    workspaceView = atom.views.getView atom.workspace
    if enabled
      workspaceView.classList.add 'block-cursor-pulse'
    else
      workspaceView.classList.remove 'block-cursor-pulse'

module.exports = new BlockCursor()
