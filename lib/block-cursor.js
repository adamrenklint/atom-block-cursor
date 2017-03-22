'use babel';
import 'object-assign-shim';
import {Disposable, CompositeDisposable} from 'atom';

// helper functions

// get the key in namespace
function getConfig(key, namespace = 'block-cursor') {
  return atom.config.get(key ? `${namespace}.${key}` : namespace);
}

// set the key in namespace
function setConfig(key, value, namespace = 'block-cursor') {
  return atom.config.set(`${namespace}.${key}`, value);
}

// get a clone of the global config
function getGlobalConfig() {
  var config = Object.assign({}, getConfig('global'));
  Object.assign(config.blinkOn, getConfig('global.blinkOn'));
  Object.assign(config.blinkOff, getConfig('global.blinkOff'));
  return config;
}

// convert a color to a string
function toRGBAString(color) {
  if(typeof color == 'string') return color;
  if(typeof color.toRGBAString == 'function') return color.toRGBAString();
  return `rgba(${color.red}, ${color.green}, ${color.blue}, ${color.alpha})`;
}

// private API

// keep a reference to the stylesheet
var style;

// create a stylesheet element and
// attach it to the DOM
function setupStylesheet() {
  style = document.createElement('style');
  style.type = 'text/css';
  document.querySelector('head atom-styles').appendChild(style);

  // return a disposable for easy removal :)
  return new Disposable(() => {
    style.parentNode.removeChild(style);
    style = null;
  });
}

// update the stylesheet when config changes
function updateCursorStyles(config) {
  // clear stylesheet
  style.innerHTML = '';
  for(let key of Object.keys(config)) {
    // and add styles for each cursor style
    style.innerHTML += cssForCursorStyle(config[key]);
  }
}

function cssForCursorStyle(cursorStyle) {
  // fill the cursor style with global as defaults
  cursorStyle = Object.assign(getGlobalConfig(), cursorStyle);
  var blinkOn = Object.assign({}, getConfig('global.blinkOn'), cursorStyle.blinkOn);
  var blinkOff = Object.assign({}, getConfig('global.blinkOff'), cursorStyle.blinkOff);
  var {selector, scopes, pulseDuration, cursorLineFix} = cursorStyle;

  // if cursor blinking is off, set the secondaryColor the same
  // as primaryColor to prevent cursor blinking in [mini] editors
  if(atom.packages.isPackageActive('cursor-blink-interval') &&
    getConfig('cursorBlinkInterval', 'cursor-blink-interval') == 0)
    blinkOff = Object.assign({}, blinkOn);

  // blink on rule
  Object.assign(blinkOn, {
    selector: selectorForScopes(selector, scopes),
    properties: Object.assign({
      // blink on background color
      'background-color': toRGBAString(blinkOn.backgroundColor),
      // pulse animation duration
      'transition-duration': `${pulseDuration}ms`,
      // cursor line fix
      // 'z-index': cursorLineFix ? 1 : -1 // @TODO: enable this when a solution is found for #20
    }, createBorderStyle(blinkOn)),
  });
  // end blink on rule

  // blink off rule
  Object.assign(blinkOff, {
    selector: selectorForScopes(selector, scopes, true),
    properties: {},
  });
  if(blinkOff.backgroundColor.alpha == 0 && (blinkOff.borderWidth == 0 ||
    blinkOff.borderStyle == 'none' || blinkOff.borderColor.alpha == 0)) {
    // better animation performance by animating opacity
    // if blink off cursor is invisible
    blinkOff.properties.opacity = 0;
  } else {
    Object.assign(blinkOff.properties, {
      // blink off background color
      'background-color': toRGBAString(blinkOff.backgroundColor),
    }, createBorderStyle(blinkOff));
  }
  // end blink off rule

  return createCSSRule(blinkOn) + createCSSRule(blinkOff);
}

// create a css properties object for given border properties
function createBorderStyle({borderWidth, borderStyle, borderColor}) {
  var borderString = `${borderWidth}px solid ${toRGBAString(borderColor)}`;
  switch(borderStyle) {
    case 'bordered-box':
      // border on all sides
      return { border: borderString };
    case 'i-beam':
      // border on left side
      return { border: 'none', 'border-left': borderString };
    case 'underline':
      // border on bottom side
      return { border: 'none', 'border-right': borderString };
    default:
      // no border
      return { border: 'none' };
  }
}

// create a css rule from a selector and an
// object containint propertyNames and values
// of the form
// <selector> {
//    <propertyName1>: <value1>;
//    <propertyName2>: <value2>;
//    ...
// }

function createCSSRule({selector, properties}) {
  return `${selector} { ${Object.keys(properties).map((key) => `${key}: ${properties[key]};`).join('')} }`;
}

// creates a css selector for the given scopes
// @param base: selector that selects the atom-text-editor element
// @param scopes: array of scopes to select
// @param blinkOff: create a blink-off selector?
function selectorForScopes(base, scopes, blinkOff = '') {
  var selectors = [];

  function grammarSelectorsForScopeName(scopeName) {
    return scopeName.split('.').map(scope => `[data-grammar~="${scope}"]`).join('');
  }

  if(blinkOff) blinkOff = '.blink-off';

  for(let scopeName of scopes) {
    let grammarSelectors = scopeName == '*' ? '' : grammarSelectorsForScopeName(scopeName);
    selectors.push(`${base}${grammarSelectors}.editor .cursors${blinkOff} .cursor`);
  }
  return selectors.join(',');
}

// add a custom cursor to the config. an easy
// shortcut when you want to define a new cursor type
function addCustomCursor() {
  var i = 0;
  while(getConfig(`custom-${i}`)) i++;
  setConfig(`custom-${i}`, getGlobalConfig());
}

// public API

// module.exports = BlockCursor = {
const config = {
  global: {
    type: 'object',
    properties: {
      scopes: {
        type: 'array',
        default: [ '*' ],
      },
      selector: {
        type: 'string',
        default: 'atom-text-editor',
      },
      blinkOn: {
        type: 'object',
        properties: {
          backgroundColor: {
            type: 'color',
            default: '#393939',
          },
          borderWidth: {
            type: 'integer',
            default: 1,
            minimum: 0,
          },
          borderStyle: {
            type: 'string',
            default: 'none',
            enum: [
              'none',
              'bordered-box',
              'i-beam',
              'underline',
            ],
          },
          borderColor: {
            type: 'color',
            default: 'transparent',
          },
        },
      },
      blinkOff: {
        type: 'object',
        properties: {
          backgroundColor: {
            type: 'color',
            default: 'transparent',
          },
          borderWidth: {
            type: 'integer',
            default: 1,
            minimum: 0,
          },
          borderStyle: {
            type: 'string',
            default: 'none',
            enum: [
              'none',
              'bordered-box',
              'i-beam',
              'underline',
            ],
          },
          borderColor: {
            type: 'color',
            default: 'transparent',
          },
        },
      },
      pulseDuration: {
        type: 'integer',
        default: 0,
        minimum: 0,
      },
      cursorLineFix: {
        description: 'Temporarily ignored (always true) because of an issue with the tile rendering introduced in Atom 0.209.0.',
        type: 'boolean',
        default: false,
      },
    },
  },
};

var disposables;

function activate() {
  // wait for cursor-blink-interval package to activate
  // if it is loaded
  Promise.resolve(
    atom.packages.isPackageLoaded('cursor-blink-interval') &&
      atom.packages.activatePackage('cursor-blink-interval')
  ).then(function go() {
    disposables = new CompositeDisposable(
      setupStylesheet(),
      atom.config.observe('block-cursor', updateCursorStyles),
      atom.commands.add('atom-workspace', 'block-cursor:new-custom-cursor', addCustomCursor)
    );
  }).catch(error => {
    console.error(error.message);
  });
}

function deactivate() {
  disposables.dispose();
  disposables = null;
}

export {config, activate, deactivate};
