
_ = require 'prelude-ls'
path = require 'path'

startsWith = (xs, x) ->
   if x |> _.empty then
      true
   else
      ((x |> _.head) == (xs |> _.head)) and ((xs |> _.tail) `startsWith` (x |> _.tail))

deepcopy = (obj) -> obj |> JSON.stringify |> JSON.parse

printHelp = (cmdtree, cmd) ->
   console.log """
      \t
         Usage: #{cmd |> _.Str.join ' '} [cmds] [options]
   """

   if cmdtree._help? then
      console.log """
         \t
            #{cmdtree._help}
      """

   subcmds = cmdtree
               |> _.Obj.obj-to-pairs
               |> _.reject ([key, value]) -> key `startsWith` "_"

   if subcmds |> _.empty then
      # print available options
      console.log """
         \t
            Options:
      """
      cmdtree._opts
         |> _.Obj.obj-to-pairs
         |> _.each ([key, value]) ->
            if value._default? then
               console.log """
                  \t --#{key}: #{value._help} (default: #{value._default})
               """
            else
               console.log """
                  \t --#{key}: #{value._help}
               """
   else
      # print subcommands
      console.log """
         \t
            Subcommands:
      """
      subcmds |> _.each ([key, value]) ->
         console.log """
            \t #{key}: #{value._help}
         """

   console.log ""

executeCmdTree = (cmdtree, argv, acc_cmd, acc_opts) ->

   #console.log """
   #   Running executeCmdTree:
   #      argv: #{argv}
   #      acc_cmd: #{acc_cmd}
   #      acc_opts: #{JSON.stringify acc_opts}
   #"""

   if argv |> _.empty then
      # No more args to parse
      #
      if cmdtree._cmd? then
         # Awesome, ready to execute the command, unless --help was specified
         #
         if acc_opts.help? then
            printHelp cmdtree, acc_cmd
         else
            # Merge in opts that have a default value
            cmdtree._opts
               |> _.Obj.obj-to-pairs
               |> _.filter ([key,value]) -> (value._default?)
               |> _.map ([key,value]) -> [key,value._default]
               |> _.each ([key,value]) ->
                  # Mutate the acc_opts with missing default values (naughty but ok...?)
                  if acc_opts."#{key}" == undefined then
                     acc_opts."#{key}" = value

            # Are any mandatory options missing?
            missing = cmdtree._opts
               |> _.Obj.obj-to-pairs
               |> _.filter ([key, value]) -> value._required and acc_opts."#{key}" == undefined
               |> _.map ([key, value]) -> key

            if not (missing |> _.empty) then
               console.log "Missing mandatory fields: #{missing |> _.Str.join ', '}"
               printHelp cmdtree, acc_cmd
            else
               cmdtree._cmd acc_opts
      else
         # Unfortunately we don't have a solution
         # so maybe we have help available, or its an ERROR
         #
         console.log "Unable to determine command"
         if cmdtree._help? then
            # Cool. Print out the help for this particular subtree
            #
            printHelp cmdtree, acc_cmd
         else
            console.log "Unable to determine function, or incomplete cmdtree definition"

   else
      argument = argv |> _.head

      if argument `startsWith` "--" then
         argument = argument |> _.drop 2

         # Force --help into the cmdtree._opts obj (weird but true)
         cmdtree.{}_opts.help = {_help: "Show this help", _default: false}

         # Look for the option in the _opts definition
         opts = cmdtree._opts."#{argument}"
         if opts == undefined then
            console.log "Unable to process option \"#{argument}\""
            printHelp cmdtree, acc_cmd
         else
            # Cool, we got a valid option.
            new_acc_opts = acc_opts |> deepcopy
            if opts._count == undefined or opts._count == 0 then
               # Single count option (true/false), therefore it's true if specified
               new_acc_opts."#{argument}" = true
               executeCmdTree (cmdtree), (argv |> _.tail), (acc_cmd), (new_acc_opts)
            else
               # Otherwise we need to eat up additional args on the cmdline
               optarg = argv |> _.drop 1 |> _.take opts._count
               new_acc_opts."#{argument}" = optarg |> _.Str.join ' '
               executeCmdTree (cmdtree), (argv |> _.drop (1 + opts._count)), (acc_cmd), (new_acc_opts)
      else
         subtree = cmdtree."#{argument}"
         if subtree == undefined then
            console.log "Unable to process command \"#{argument}\""
            printHelp cmdtree, acc_cmd
         else
            executeCmdTree (subtree), (argv |> _.tail), (acc_cmd ++ [argument]), (acc_opts)


module.exports = do
   execute: (cmdtree, argv) ->
      executeCmdTree cmdtree, (argv |> _.drop 2), [(argv |> _.at 1 |> path.basename)], {}
