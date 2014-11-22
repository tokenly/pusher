###
#
# This server runs a Faye websocket messaging hub
#
###

pusherPort = process.env.PUSHER_PORT or 8200
pusherHost = process.env.PUSHER_HOST or "localhost"

http = require('http')
faye = require('faye')

server = http.createServer()
bayeux = new faye.NodeAdapter({mount: '/public'})

console.log "starting server on port #{pusherPort}"
bayeux.attach(server)
server.listen(pusherPort)

bayeux.on 'subscribe', (clientId, channel)->
    console.log('[SUBSCRIBE] ' + clientId + ' -> ' + channel)

console.log "subscribing to http://localhost:#{pusherPort}/public"
client = new faye.Client("http://localhost:#{pusherPort}/public")
n = 0
setInterval ()->
    res = client.publish('/tick', {ts: Date.now()})
    # console.log "sending tick #{Date.now()}",res
    return
, 30000
