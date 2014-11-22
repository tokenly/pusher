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

console.log "subscriing to http://#{pusherHost}:#{pusherPort}/public"
client = new faye.Client("http://#{pusherHost}:#{pusherPort}/public")
n = 0
setInterval ()->
    client.publish('/tick', {ts: Date.now()})
, 30000
