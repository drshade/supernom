
_ = require 'prelude-ls'

string-starts-with = (xs, x) ->
   | x |> _.empty => true
   | otherwise =>
      ((x |> _.head) == (xs |> _.head)) and ((xs |> _.tail) `string-starts-with` (x |> _.tail))

string-ends-with = (xs, x) ->
   | x |> _.empty => true
   | otherwise =>
      ((x |> _.last) == (xs |> _.last)) and ((xs |> _.initial) `string-ends-with` (x |> _.initial))

deepcopy = (obj) -> obj |> JSON.stringify |> JSON.parse

module.exports =
   string-starts-with: string-starts-with
   string-ends-with: string-ends-with
   deepcopy: deepcopy
