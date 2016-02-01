_ = require 'prelude-ls'

startsWith = (xs, x) ->
   if x |> _.empty then
      true
   else
      ((x |> _.head) == (xs |> _.head)) and ((xs |> _.tail) `startsWith` (x |> _.tail))

extractStoryVariables = (story) ->
   # eg "scale {service} to {number} instances"
   variable_pattern = /{(\S+)}/g

   # Nasty nasty way of interacting with regex in js
   variables = []
   while (matched = variable_pattern.exec story)
      variables.push matched[1]

   variables

# Doesn't deal with comments in the function
extractFunctionVariables = (a_function) ->
   # Parse the "function (a, b, c) {...}" bit
   #
   function_pattern = /function\s*\((.*)\)/g
   function_string = a_function.toString!

   # Parse the "(a, b, c, d)" bit
   #
   parameter_string = function_pattern.exec function_string
   parameter_pattern = /\s*([^,\s]+)\s*,?/g
   parameters = []
   while (matched = parameter_pattern.exec parameter_string.1)
      parameters.push matched[1]

   parameters

# Simpler tokeniser - probably should do this better to include support for
# quoted values e.g. "example name" as a single token
tokenise = (x) -> (x.match /\S+/g) || []

list-to-obj = (root, xs) -->
   lastitem = xs
      |> _.fold do
         (state, item) ->
            if not state."#{item}"? then
               state."#{item}" = {}
            state."#{item}"
         root
   lastitem

module.exports =
   execute: (cmdtree, cmdtext) ->
      root = {}
      cmdtree
         |> _.Obj.obj-to-pairs
         |> _.each ([story, handler]) ->
            tokens = tokenise story
            last = tokens |> list-to-obj root
            last.handler = handler

      # Cool, now we can check everything matches (i.e. whatever the dev told the
      # story matches what the function accepts)
      # TBD

      #console.log "cmdtree: #{JSON.stringify root, null, 3}"

      cmdtokens = tokenise cmdtext
      [func, params] =
         cmdtokens
            |> _.fold do
               ([func, params, subtree], token) ->
                  if subtree."#{token}"? then
                     # Deepen
                     [subtree."#{token}".handler, params, subtree."#{token}"]

                  else
                     # Could be a variable, find the first one
                     variable =
                        subtree
                           |> _.Obj.obj-to-pairs
                           |> _.map ([k,v]) -> k
                           |> _.find (k) -> k `startsWith` '{'

                     if variable? then
                        # Deepen
                        #console.log "Variable: #{variable} = #{token}"
                        params."#{variable}" = token
                        [subtree."#{variable}".handler, params, subtree."#{variable}"]
                     # Can't match the token, just move onto the next one?
                     else
                        [func, params, subtree]

               [undefined, {}, root]

      if not func? then
         console.log "Unable to resolve function call"

      else
         # Extract variables from function
         function_variables = extractFunctionVariables func
         #console.log "#{JSON.stringify params, null, 2}"
         values =
            function_variables
               |> _.map (variable) -> params."{#{variable}}"
         _.apply func, values
