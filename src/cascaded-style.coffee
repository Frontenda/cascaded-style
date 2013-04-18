# Return the cascaded style for an element. Uses getMatchedCSSRules in chrome
# and a polyfill in firefox.
#
# options:
#   polyfill - bool; will use the polyfill getMatchedCSSRules.
#              Useful for when crossdomain sheets.
#              default: false
#   properties - List of properties to return; If a property's cascaded style
#                is not available from a stylesheet, will return computed style.
#                default: null
#   replaceInherit - bool; will replace css values 'inherit' with their computed counterpart
#                    default: false
$.fn.cascadedStyle = (options) ->
  _inspectCSS($(this), options)

# Private: Inspects the CSS of a given DOM element.
#
# el - A DOM element.
#
# Returns an object whose properties are CSS property names and values are
# their coresponding CSS values.
_inspectCSS = (el, options={}) ->
  func = window.getMatchedCSSRules
  func = window.getMatchedCSSRulesPolyfill unless func and not options.polyfill
  options.function = func

  _inspect(el, options)

# Private: Polyfill for getMatchedCSSRules. Also useful for when some of the
# stylesheets are crossdomain. In the case of crossdomain stylesheets, the
# real getMatchedCSSRules will just return null. Maddening.
#
# Code from: https://gist.github.com/3033012 revision 732e1c
#
# Returns nothing.
window.getMatchedCSSRulesPolyfill = (element) ->
  result = []
  styleSheets = Array::slice.call(document.styleSheets)

  while sheet = styleSheets.shift()
    sheetMedia = sheet.media.mediaText
    continue if sheet.disabled or not sheet.cssRules
    continue if sheetMedia.length and not window.matchMedia(sheetMedia).matches

    for rule in sheet.cssRules
      if rule.stylesheet
        # Is an imported sheet (@import). add imported stylesheet to the
        # stylesheets array
        styleSheets.push(rule.stylesheet)
        # and skip this rule
        continue
      else if rule.media
        # Is a media query. add this rule to the stylesheets array since it quacks
        # like a stylesheet (has media & cssRules attibutes)
        styleSheets.push(rule)
        # and skip it
        continue

      fn = element.matchesSelector or element.mozMatchesSelector or element.webkitMatchesSelector
      result.push(rule) if fn.call(element, rule.selectorText)

  _sortBySpecificity(result)

# Private: Sort a list of css rules by their specificity. Most specific is
# last.
#
# rules - a list of CssRules.
#
# Returns a sorted list of rules
_sortBySpecificity = (rules) ->
  spec = {}
  getSpec = (rule) =>
    unless spec[rule.selectorText]?
      spec[rule.selectorText] = $.specificity(rule.selectorText)
    spec[rule.selectorText]

  cmp = (a, b) ->
    return getSpec(a) - getSpec(b)

  rules.sort(cmp)
  rules

# Private: Inspects the CSS of a given DOM element using the WebKit's
# getMatchedCSSRules.
#
# el - A DOM element.
# isRoot - inspecting the root element?
#
# Returns an object whose properties are CSS property names and values are
# their corresponding CSS values.
_inspect = (el, options={}) ->
  options.function = window.getMatchedCSSRules unless options.function

  results = {}
  important = {}
  $el = $(el)
  matchedRules = options.function.call(window, $el[0], null)
  matchedRules = Array::slice.call(matchedRules) # convert into a real array

  # Append style from the style attribute. End of the array -> most important.
  # Use the values in the style attribute (not el.style) as they aren't munged
  # by the browser.
  matchedRules.push(cssText: ($el.attr('style') or ''))

  for matchedRule in matchedRules
    properties = {}
    cssText = matchedRule.cssText
    cssText = cssText.match(/{([^}]*)}/)[1] if cssText.indexOf('{') > -1
    for property in cssText.split(';')
      # we cant simply split on the colon for the sake of urls.
      sprop = property.split(':')
      name = sprop[0].trim()
      value = sprop.slice(1).join(':').trim()

      isImportant = /\!\s*important/g.test(value)
      if isImportant
        value = value.replace(/\!\s*important/g, '').trim()
        important[name] = true # this property now only accepts important values.

      properties[name] = value if (isImportant and important[name]) or not important[name]

    for property, value of properties
      results[property] = value if value

  results = _filterProperties(el, results, options.properties) if options.properties
  results = _replaceInherit(el, results) if options.replaceInherit
  results

# Private: Returns a dict of css properties with only the properties
# specified. If a property is not already in css, it's computed style will be
# pulled from el. Think of it like a specialized _.pick()
#
# el - a jquery element
# css - the css dict with all cascaded styles
# properties - a list of properties
#
# Returns a dict
_filterProperties = (el, css, properties) ->
  return css unless properties and properties.length

  style = el.computedStyle()

  results = {}
  for prop in properties
    results[prop] = if prop of css then css[prop] else style[prop]

  results

# Private: Replaced any 'inherit's with their computed style.
#
# el - a jquery element
# css - the css dict with all cascaded styles
#
# Returns a dict of css
_replaceInherit = (el, css) ->
  style = el.computedStyle()

  for prop, value of css
    css[prop] = style[prop] if value.indexOf('inherit') == 0

  css

# Private: Inspects the CSS of a given DOM element using the DOM standard.
#
# el - A DOM element.
# isRoot - inspecting the root element?
#
# Returns an object whose properties are CSS property names and values are
# their coresponding CSS values.
_inspectWithListOfRules = (el, isRoot) ->
  el = $(el)

  style = el.computedStyle()
  results = {}
  $.each style, (key) =>
    property = style[key]
    return unless @_includeCssProperty(property)
    results[property] = style.getPropertyValue(property)

  results

