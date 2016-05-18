
_ = require 'prelude-ls'

string-starts-with = (xs, x) ->
   if x |> _.empty then
      true
   else
      ((x |> _.head) == (xs |> _.head)) and ((xs |> _.tail) `string-starts-with` (x |> _.tail))

string-ends-with = (x) ->
   x

module.exports =
   string-starts-with: string-starts-with
   string-ends-with: string-ends-with
