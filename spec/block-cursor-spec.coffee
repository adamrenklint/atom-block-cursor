fs = require 'fs'
path = require 'path'
blockCursor = require '../lib/block-cursor'

describe 'Block Cursor', ->
  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage 'block-cursor'

  it 'adds the block-cursor class to the workspaceView', ->
    workspaceView = atom.views.getView atom.workspace
    expect(workspaceView.className).toMatch /\s*block-cursor\s*/

  describe 'config', ->
    colorsFile = path.join __dirname, '..', 'styles', 'includes', 'colors.less'

    describe 'the primary color option', ->
      it 'changes only the first line of styles/colors.less', ->
        initialLines = fs.readFileSync(colorsFile, 'utf8').split '\n'
        newColor = do ->
          initialColor = atom.config.get 'block-cursor.primaryColor'
          initialColor.red = (initialColor.red + 1) % 256
          initialColor
        atom.config.set 'block-cursor.primaryColor', newColor
        newLines = fs.readFileSync(colorsFile, 'utf8').split '\n'
        expect(newLines[0]).not.toEqual(initialLines[0])
        expect(newLines[1]).toEqual(initialLines[1])

    describe 'the secondary color option', ->
      it 'changes only the second line of styles/colors.less', ->
        initialLines = fs.readFileSync(colorsFile, 'utf8').split '\n'
        newColor = do ->
          initialColor = atom.config.get 'block-cursor.secondaryColor'
          initialColor.red = (initialColor.red + 1) % 256
          initialColor
        atom.config.set 'block-cursor.secondaryColor', newColor
        newLines = fs.readFileSync(colorsFile, 'utf8').split '\n'
        expect(newLines[0]).toEqual(initialLines[0])
        expect(newLines[1]).not.toEqual(initialLines[1])

    describe 'the enablePulse option', ->
      it 'adds the block-cursor-pulse class to the workspaceView if enabled', ->
        workspaceView = atom.views.getView atom.workspace
        atom.config.set 'block-cursor.enablePulse', true
        expect(workspaceView.className).toMatch /\s*block-cursor-pulse\s*/

      it 'removes the block-cursor-pulse class from the workspaceView if disabled', ->
        workspaceView = atom.views.getView atom.workspace
        atom.config.set 'block-cursor.enablePulse', false
        expect(workspaceView.className).not.toMatch /block-cursor-pulse/