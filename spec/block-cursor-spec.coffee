'use strict'
fs = require 'fs'
BlockCursor = require '../lib/block-cursor'

changeColor = (color) ->
  color.red = (color.red + 1) % 256
  color

changeDuration = (duration) ->
  (duration + 100) % 500

describe 'Block Cursor', ->
  beforeEach -> waitsForPromise -> atom.packages.activatePackage 'block-cursor'

  describe 'The primary color option', ->
    it 'alters styles/includes/vars.less when changed', ->
      initialVars = fs.readFileSync BlockCursor.varsStylesheet, 'utf8'
      initialColor = atom.config.get 'block-cursor.primaryColor'
      atom.config.set 'block-cursor.primaryColor', changeColor initialColor
      newVars = fs.readFileSync BlockCursor.varsStylesheet, 'utf8'
      expect(initialVars).not.toEqual(newVars)

  describe 'The secondary color option', ->
    it 'alters styles/includes/vars.less when changed', ->
      initialVars = fs.readFileSync BlockCursor.varsStylesheet, 'utf8'
      initialColor = atom.config.get 'block-cursor.secondaryColor'
      atom.config.set 'block-cursor.secondaryColor', changeColor initialColor
      newVars = fs.readFileSync BlockCursor.varsStylesheet, 'utf8'
      expect(initialVars).not.toEqual(newVars)

  describe 'The pulse duration option', ->
    it 'alters styles/includes/vars.less when changed', ->
      initialVars = fs.readFileSync BlockCursor.varsStylesheet, 'utf8'
      initialDuration = atom.config.get 'block-cursor.pulseDuration'
      atom.config.set 'block-cursor.pulseDuration', changeDuration initialDuration
      newVars = fs.readFileSync BlockCursor.varsStylesheet, 'utf8'
      expect(initialVars).not.toEqual(newVars)