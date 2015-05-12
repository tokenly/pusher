###
#
# This server runs a Faye websocket messaging hub
#
###

pusherPort = process.env.PUSHER_PORT or 8200
secret = process.env.PUSHER_PASSWORD or ''
debug = process.env.DEBUG or false

pusherHost = "localhost"


http = require('http')
faye = require('faye')

server = http.createServer()
bayeux = new faye.NodeAdapter({mount: '/public'})

figlet = require('figlet');

###############################################################
# SETUP

if secret.length > 0
    bayeux.addExtension({
        incoming: (message, callback)->
            if not message.channel.match(/^\/meta\//)
                password = message.ext?.password
                if password != secret
                    if debug then console.log "bad password: #{password}"
                    message.error = '403::Password required'
                else
                    if debug then console.log "message received",message
            callback(message)
            return

        outgoing: (message, callback)->
            delete message.ext.password if (message.ext)
            callback(message)
            return
    })

###############################################################
# Run

run = ()->
    console.log "starting server on port #{pusherPort}"
    bayeux.attach(server)
    server.listen(pusherPort)

    bayeux.on 'subscribe', (clientId, channel)->
        console.log("[SUBSCRIBE] #{clientId} -> #{channel}")
        return

    console.log "subscribing to http://#{pusherHost}:#{pusherPort}/public"
    client = new faye.Client("http://#{pusherHost}:#{pusherPort}/public")
    # n = 0
    # setInterval ()->
    #     res = client.publish('/tick', {ts: Date.now()})
    #     if debug then console.log "sending tick #{Date.now()}",res
    #     return
    # , 30000


###############################################################
# Init

figlet.text('Tokenly Pusher', 'Slant', (err, data)->
    process.stdout.write(data+"\n\n")
    return
)

setTimeout ()->
    run()
, 10
