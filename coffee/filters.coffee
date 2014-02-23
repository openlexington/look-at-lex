lex_app.filter 'startFrom', ->
  (input, start) ->
    start = Math.abs(start)
    input.slice(start)

lex_app.filter 'range', ->
  (input, total) ->
    total = parseInt(total, 10)
    for i in [0...total]
      input.push i
    input
