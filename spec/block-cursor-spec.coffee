blockCursor = require '../lib/block-cursor'

testColor = (index) ->
  configKey = if index > 0 then 'secondaryColor' else 'primaryColor'
  style = blockCursor.getColorStyleElement()

  initialColor = atom.config.get "block-cursor.#{configKey}"
  initialRule = style.sheet.cssRules[index].cssText

  newColor = initialColor
  newColor.red = (newColor.red + 1) % 256
  atom.config.set "block-cursor.#{configKey}", newColor
  newRule = style.sheet.cssRules[index].cssText

  expect(newRule).not.toEqual initialRule
  expect(newRule).toMatch /rgba?\(([0-9]{1,3}(,?\s?)?){3,4}\)/

describe 'Block Cursor', ->
  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage 'block-cursor'

  it 'adds the block-cursor class to the workspaceView', ->
    workspaceView = atom.views.getView atom.workspace
    expect(workspaceView.className).toMatch /\s*block-cursor\s*/

  describe 'the style element added by this package', ->
    styleElement = blockCursor.getColorStyleElement()

    it 'is in the atom-styles element in the head element', ->
      expect(styleElement.parentNode).toEqual document.querySelector 'head atom-styles'
      expect(styleElement.parentNode.parentNode).toEqual document.head


    it 'has two rules', ->
      expect(styleElement.sheet.cssRules.length).toEqual(2)

  describe 'config', ->
    describe 'the primary color option', ->
      it 'changes the first rule of the packages stylesheet', ->
        testColor 0

    describe 'the secondary color option', ->
      it 'changes the second rule of the packages stylesheet', ->
        testColor 1

    describe 'the enablePulse option', ->
      it 'adds the block-cursor-pulse class to the workspaceView if enabled', ->
        workspaceView = atom.views.getView atom.workspace
        atom.config.set 'block-cursor.pulseEnabled', true
        expect(workspaceView.className).toMatch /\s*block-cursor-pulse\s*/

      it 'removes the block-cursor-pulse class from the workspaceView if disabled', ->
        workspaceView = atom.views.getView atom.workspace
        atom.config.set 'block-cursor.pulseEnabled', false
        expect(workspaceView.className).not.toMatch /block-cursor-pulse/