
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

# Private: Polyfill for getMatchedCSSRules.
# Code from: https://gist.github.com/3033012 revision 732e1c
#
# Returns nothing.
window.getMatchedCSSRulesPolyfill = (element) ->
  result = []
  style_sheets = Array::slice.call(document.styleSheets)

  while sheet = style_sheets.shift()
    sheet_media = sheet.media.mediaText
    continue if sheet.disabled or not sheet.cssRules
    continue if sheet_media.length and not window.matchMedia(sheet_media).matches

    for rule in sheet.cssRules
      if rule.stylesheet
        # add imported stylesheet to the stylesheets array
        style_sheets.push(rule.stylesheet)
        # and skip this rule
        continue
      else if rule.media
        # add this rule to the stylesheets array since it quacks like
        # a stylesheet (has media & cssRules attibutes)
        style_sheets.push(rule)
        # and skip it
        continue

      fn = element.matchesSelector or element.mozMatchesSelector or element.webkitMatchesSelector
      if fn.call(element, rule.selectorText)
        result.push(rule)

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

# Private:
_filterProperties = (el, css, properties) ->
  return css unless properties and properties.length

  style = el.computedStyle()

  results = {}
  for prop in properties
    results[prop] = if prop of css then css[prop] else style[prop]

  results

# Private:
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

