filter = (array, term) ->
  matcher = new RegExp($.ui.autocomplete.escapeRegex(term), "i")
  $.grep array, (value) ->
    matcher.test $("<div>").html(value.label or value.value or value).text()

proto = $.ui.autocomplete::
initSource = proto._initSource
$.extend proto,
  _initSource: ->
    if @options.html and $.isArray(@options.source)
      @source = (request, response) ->
        response filter(@options.source, request.term)
    else
      initSource.call this

  _renderItem: (ul, item) ->
    $("<li></li>").data("item.autocomplete", item).append($("<a href='" + (if item.invite then item.invite else (if item.veteran then item.position_url else item.profile_url)) + "'></a>")[(if @options.html then "html" else "text")](item.label)).appendTo ul

angular.module("MyModule", []).directive "autoComplete", () ->
  (scope, elm, attrs) ->
    scope.$watch attrs.uiItems, (newValue) ->
      if newValue
        elm.autocomplete
          source: newValue
        elm.keyup (e) ->
          if e.keyCode is 13
            guy = $(this).val()
            $.each newValue, (i, v) ->
              if v.name is guy
                window.location.assign v.invite
                return
