lex_app.filter 'startFrom', ->
  (input, start) ->
    start = Math.abs(start)
    input.slice(start)
