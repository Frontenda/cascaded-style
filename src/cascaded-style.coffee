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

    # most browsers have window.matchMedia, but some (jasmine headless webkit) dont
    continue if sheetMedia.length and (not window.matchMedia or not window.matchMedia(sheetMedia).matches)

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
      try
        # in try/catch as there might be an 'invalid' selector.
        result.push(rule) if fn.call(element, rule.selectorText)
      catch e
        ;

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

  # Append style from the element. End of the array -> most important.
  matchedRules.push($el[0])
  matchedRules.reverse()

  for matchedRule in matchedRules
    style = matchedRule.style

    # Will get all the atomic properties (i.e. background-position-x, not
    # background). Atomic properties are important for accuracy. Otherwise we
    # might get in the situation where one rule specifies border:none, and
    # another specifies borders via border-width, border-style, and border-
    # color, but all the rules make it into the result.
    for property in style
      isImportant = style.getPropertyPriority(property)

      if not results[property]?
        results[property] = style.getPropertyValue(property)
      else if isImportant and not important[property]
        results[property] = style.getPropertyValue(property)
        important[property] = true

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
    css[prop] = style[prop] if value? and value.indexOf('inherit') == 0

  css

