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
