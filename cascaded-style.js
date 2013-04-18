// Generated by CoffeeScript 1.4.0
(function() {
  var _inspect, _inspectCSS, _inspectWithListOfRules, _intelligentReplace, _sortBySpecificity;

  $.fn.getMatchedStyle = function(options) {
    return _inspectCSS($(this), options);
  };

  _inspectCSS = function(el, options) {
    var css, func;
    if (options == null) {
      options = {};
    }
    func = window.getMatchedCSSRules;
    if (!(func && !options.polyfill)) {
      func = window.getMatchedCSSRulesPolyfill;
      console.log('using polyfill');
    }
    css = _inspect(el, {
      "function": func
    });
    if (options.intelligentReplace) {
      css = _intelligentReplace(el, css, options);
    }
    return css;
  };

  window.getMatchedCSSRulesPolyfill = function(element) {
    var fn, result, rule, sheet, sheet_media, style_sheets, _i, _len, _ref;
    result = [];
    style_sheets = Array.prototype.slice.call(document.styleSheets);
    while (sheet = style_sheets.shift()) {
      sheet_media = sheet.media.mediaText;
      if (sheet.disabled || !sheet.cssRules) {
        continue;
      }
      if (sheet_media.length && !window.matchMedia(sheet_media).matches) {
        continue;
      }
      _ref = sheet.cssRules;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        rule = _ref[_i];
        if (rule.stylesheet) {
          style_sheets.push(rule.stylesheet);
          continue;
        } else if (rule.media) {
          style_sheets.push(rule);
          continue;
        }
        fn = element.matchesSelector || element.mozMatchesSelector || element.webkitMatchesSelector;
        if (fn.call(element, rule.selectorText)) {
          result.push(rule);
        }
      }
    }
    return _sortBySpecificity(result);
  };

  _sortBySpecificity = function(rules) {
    var cmp, getSpec, spec,
      _this = this;
    spec = {};
    getSpec = function(rule) {
      if (spec[rule.selectorText] == null) {
        spec[rule.selectorText] = $.specificity(rule.selectorText);
      }
      return spec[rule.selectorText];
    };
    cmp = function(a, b) {
      return getSpec(a) - getSpec(b);
    };
    rules.sort(cmp);
    return rules;
  };

  _inspect = function(el, options) {
    var $el, cssText, important, isImportant, matchedRule, matchedRules, name, properties, property, results, sprop, value, _i, _j, _len, _len1, _ref;
    if (options == null) {
      options = {};
    }
    if (!options["function"]) {
      options["function"] = window.getMatchedCSSRules;
    }
    results = {};
    important = {};
    $el = $(el);
    matchedRules = options["function"].call(window, $el[0], null);
    matchedRules = Array.prototype.slice.call(matchedRules);
    matchedRules.push($el[0].style);
    console.log(matchedRules);
    for (_i = 0, _len = matchedRules.length; _i < _len; _i++) {
      matchedRule = matchedRules[_i];
      properties = {};
      cssText = matchedRule.cssText;
      if (cssText.indexOf('{') > -1) {
        cssText = cssText.match(/{([^}]*)}/)[1];
      }
      _ref = cssText.split(';');
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        property = _ref[_j];
        sprop = property.split(':');
        name = sprop[0].trim();
        value = sprop.slice(1).join(':').trim();
        isImportant = /\!\s*important/g.test(value);
        if (isImportant) {
          value = value.replace(/\!\s*important/g, '').trim();
          important[name] = true;
        }
        if ((isImportant && important[name]) || !important[name]) {
          properties[name] = value;
        }
      }
      for (property in properties) {
        value = properties[property];
        if (value) {
          results[property] = value;
        }
      }
    }
    return results;
  };

  _intelligentReplace = function(el, css, options) {
    var property, shouldReplaceWithComputedStyle, value;
    if (options == null) {
      options = {};
    }
    shouldReplaceWithComputedStyle = function(property, value) {
      return value.indexOf('initial') === 0;
    };
    for (property in css) {
      value = css[property];
      if (shouldReplaceWithComputedStyle(property, value)) {
        css[property] = el.css(property);
      }
    }
    return css;
  };

  _inspectWithListOfRules = function(el, isRoot) {
    var results, style,
      _this = this;
    el = $(el);
    style = el.computedStyle();
    results = {};
    $.each(style, function(key) {
      var property;
      property = style[key];
      if (!_this._includeCssProperty(property)) {
        return;
      }
      return results[property] = style.getPropertyValue(property);
    });
    return results;
  };

}).call(this);
