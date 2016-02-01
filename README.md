# supernom
Super simple command line parser and execution framework.

### cmdnom

```livescript
cmdnom = (require './supernom').cmdnom

cmdtree = do
   _help: 'Example application showing off the power of supernom'

cmdtree <<<
   task1:
      _opts:
         parameter1:
            _help: 'Specify the value for parameter1'
            _count: 1
            _required: true
         parameter2:
            _help: 'Specify the value for parameter1'
            _count: 1
            _default: 'value2'
      _help: 'Execute the example task1 task'
      _cmd: (opts) ->
         console.log "Executing task1 with parameter1: #{opts.parameter1} and parameter2: #{opts.parameter2}"

cmdtree <<<
   task2:
      _opts:
         parameter3:
            _help: 'Specify the value for parameter3'
            _count: 1
            _required: true
         parameter4:
            _help: 'Specify the value for parameter4'
            _count: 1
            _default: 'value2'
      _help: 'Execute the example task2 task'
      _cmd: (opts) ->
         console.log "Executing task2 with parameter3: #{opts.parameter3} and parameter4: #{opts.parameter4}"

# Run!
cmdnom.execute cmdtree, process.argv
```

### storydrive

```livescript
_ = require 'prelude-ls'
storydrive = (require './supernom').storydrive

cmdtree =
   "stop service {service}": (service) ->
      console.log "Stopping service #{service}..."

   "start service {service}": (service) ->
      console.log "Starting service #{service}..."

   "start host {hostname}": (hostname) ->
      console.log "Starting host #{hostname}..."

   "stop host {hostname}": (hostname) ->
      console.log "Stopping host #{hostname}..."

   "list units": ->
      console.log "Listing units..."

   "list hosts": ->
      console.log "Listing hosts..."

   "scale {service} to {number} instances": (number, service, dogs, cats) ->
      console.log "Scaling service #{service} to #{number} instances..."

   "check status of {service} on {host}": (service, host) ->
      console.log "Checking status of #{service} on #{host}..."

cmdtext = process.argv |> _.drop 2 |> _.Str.join ' '

# Run!
storydrive.execute cmdtree, cmdtext
```


