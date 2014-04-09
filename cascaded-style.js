// Generated by CoffeeScript 1.7.1
(function() {
  var COMPOSITES, _compositeProperty, _filterProperties, _getComputedFromStyle, _getMatchedCSSRulesPolyfill, _getWindow, _inspect, _inspectCSS, _replaceWithComputed, _sortBySpecificity;

  $.fn.cascadedStyle = function(options) {
    return _inspectCSS($(this), options);
  };

  _inspectCSS = function(el, options) {
    var func;
    if (options == null) {
      options = {};
    }
    func = _getWindow(options).getMatchedCSSRules;
    if (!(func && !options.polyfill)) {
      func = _getMatchedCSSRulesPolyfill;
    }
    options["function"] = func;
    return _inspect(el, options);
  };

  _getWindow = function(options) {
    if (options == null) {
      options = {};
    }
    return options.window || window;
  };

  _getMatchedCSSRulesPolyfill = function(element) {
    var e, fn, result, rule, sheet, sheetMedia, styleSheets, _i, _len, _ref;
    if (!element) {
      return [];
    }
    result = [];
    styleSheets = Array.prototype.slice.call(this.document.styleSheets);
    while (sheet = styleSheets.shift()) {
      try {
        sheetMedia = sheet.media.mediaText;
        sheet.cssRules;
      } catch (_error) {
        e = _error;
        continue;
      }
      if (sheet.disabled || !sheet.cssRules) {
        continue;
      }
      if (sheetMedia.length && (!this.matchMedia || !this.matchMedia(sheetMedia).matches)) {
        continue;
      }
      _ref = sheet.cssRules;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        rule = _ref[_i];
        if (rule.stylesheet) {
          styleSheets.push(rule.stylesheet);
          continue;
        } else if (rule.media) {
          styleSheets.push(rule);
          continue;
        }
        fn = element.matchesSelector || element.mozMatchesSelector || element.webkitMatchesSelector;
        try {
          if (fn.call(element, rule.selectorText)) {
            result.push(rule);
          }
        } catch (_error) {
          e = _error;
        }
      }
    }
    return result;
  };

  _sortBySpecificity = function(rules, element) {
    var cmp, getSpec, i, spec, _i, _ref;
    spec = {};
    getSpec = (function(_this) {
      return function(rule) {
        if (spec[rule.selectorText] == null) {
          spec[rule.selectorText] = $.specificity(rule.selectorText, {
            element: element
          });
        }
        return spec[rule.selectorText];
      };
    })(this);
    cmp = function(a, b) {
      var diff;
      diff = getSpec(a) - getSpec(b);
      if (!diff) {
        diff = a.__pos - b.__pos;
      }
      return diff;
    };
    for (i = _i = 0, _ref = rules.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      rules[i].__pos = i;
    }
    rules.sort(cmp);
    return rules;
  };

  _inspect = function(element, options) {
    var important, isImportant, matchedRule, matchedRules, property, results, style, value, win, _i, _j, _len, _len1;
    if (options == null) {
      options = {};
    }
    win = _getWindow(options);
    if (!options["function"]) {
      options["function"] = win.getMatchedCSSRules;
    }
    if (element instanceof jQuery) {
      element = element[0];
    }
    results = {};
    important = {};
    matchedRules = options["function"].call(win, element, null);
    matchedRules = Array.prototype.slice.call(matchedRules);
    matchedRules = _sortBySpecificity(matchedRules, element);
    matchedRules.push(element);
    matchedRules.reverse();
    for (_i = 0, _len = matchedRules.length; _i < _len; _i++) {
      matchedRule = matchedRules[_i];
      if (!(matchedRule && matchedRule.style)) {
        continue;
      }
      style = matchedRule.style;
      for (_j = 0, _len1 = style.length; _j < _len1; _j++) {
        property = style[_j];
        isImportant = style.getPropertyPriority(property);
        value = style.getPropertyValue(property);
        if ((results[property] == null) && value) {
          results[property] = value;
        } else if (value && isImportant && !important[property]) {
          results[property] = value;
          important[property] = true;
        }
      }
    }
    results = _replaceWithComputed(element, results, 'initial');
    if (options.replaceInherit) {
      results = _replaceWithComputed(element, results, 'inherit');
    }
    if (options.properties) {
      results = _filterProperties(element, results, options.properties);
    }
    return results;
  };

  _filterProperties = function(el, css, properties) {
    var computeStyle, prop, results, style, _i, _len;
    if (!(properties && properties.length)) {
      return css;
    }
    style = $(el).computedStyle();
    computeStyle = function(property) {
      var value;
      value = _compositeProperty(property, css);
      if (value == null) {
        value = _getComputedFromStyle(style, property);
      }
      return value;
    };
    results = {};
    for (_i = 0, _len = properties.length; _i < _len; _i++) {
      prop = properties[_i];
      results[prop] = prop in css ? css[prop] : computeStyle(prop);
    }
    return results;
  };

  _replaceWithComputed = function(el, css, valueToReplace) {
    var prop, style, value;
    style = $(el).computedStyle();
    for (prop in css) {
      value = css[prop];
      if ((value != null) && (value.indexOf(valueToReplace) === 0)) {
        css[prop] = _getComputedFromStyle(style, prop);
      }
    }
    return css;
  };

  _getComputedFromStyle = function(style, property) {
    if (style.getPropertyValue) {
      return style.getPropertyValue(property);
    } else {
      return style[property];
    }
  };

  _compositeProperty = function(property, css) {
    if (COMPOSITES[property]) {
      return COMPOSITES[property](css);
    }
    return null;
  };

  COMPOSITES = {
    'background-position': function(css) {
      if (css['background-position-x'] && css['background-position-y']) {
        return "" + css['background-position-x'] + " " + css['background-position-y'];
      }
      return null;
    },
    'border-left-width': function(css) {
      if (css['border-left-width-value']) {
        return css['border-left-width-value'];
      }
      return null;
    },
    'border-left-color': function(css) {
      if (css['border-left-color-value']) {
        return css['border-left-color-value'];
      }
      return null;
    },
    'border-left-style': function(css) {
      if (css['border-left-style-value']) {
        return css['border-left-style-value'];
      }
      return null;
    },
    'border-right-width': function(css) {
      if (css['border-right-width-value']) {
        return css['border-right-width-value'];
      }
      return null;
    },
    'border-right-color': function(css) {
      if (css['border-right-color-value']) {
        return css['border-right-color-value'];
      }
      return null;
    },
    'border-right-style': function(css) {
      if (css['border-right-style-value']) {
        return css['border-right-style-value'];
      }
      return null;
    }
  };

}).call(this);
