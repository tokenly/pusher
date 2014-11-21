###
#
# This server runs a Faye websocket messaging hub
#
###

pusherPort = process.env.PUSHER_PORT or 8200

http = require('http')
faye = require('faye')

server = http.createServer()
bayeux = new faye.NodeAdapter({mount: '/public'})

console.log "starting server on port #{pusherPort}"
bayeux.attach(server)
server.listen(pusherPort)

bayeux.on 'subscribe', (clientId, channel)->
    console.log('[SUBSCRIBE] ' + clientId + ' -> ' + channel)

client = new faye.Client("http://localhost:#{pusherPort}/public")
n = 0
setInterval ()->
    client.publish('/tick', {ts: Date.now()})
, 30000
