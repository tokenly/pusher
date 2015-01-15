###
#
# This server runs a Faye websocket messaging hub
#
###

pusherPort = process.env.PUSHER_PORT or 8200
pusherHost = process.env.PUSHER_HOST or "localhost"
secret = process.env.PUSHER_PASSWORD or ''


http = require('http')
faye = require('faye')

server = http.createServer()
bayeux = new faye.NodeAdapter({mount: '/public'})


if secret.length > 0
    bayeux.addExtension({
        incoming: (message, callback)->
            if not message.channel.match(/^\/meta\//)
                password = message.ext?.password
                if password != secret
                    message.error = '403::Password required'
            callback(message)
            return

        outgoing: (message, callback)->
            delete message.ext.password if (message.ext)
            callback(message)
            return
    })

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
