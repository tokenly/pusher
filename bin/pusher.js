// Generated by CoffeeScript 1.8.0

/*
 *
 * This server runs a Faye websocket messaging hub
 *
 */

(function() {
  var bayeux, debug, faye, figlet, http, pusherHost, pusherPort, run, secret, server;

  pusherPort = process.env.PUSHER_PORT || 8200;

  secret = process.env.PUSHER_PASSWORD || '';

  debug = process.env.DEBUG || false;

  pusherHost = "localhost";

  http = require('http');

  faye = require('faye');

  server = http.createServer();

  bayeux = new faye.NodeAdapter({
    mount: '/public'
  });

  figlet = require('figlet');

  if (secret.length > 0) {
    bayeux.addExtension({
      incoming: function(message, callback) {
        var password, _ref;
        if (!message.channel.match(/^\/meta\//)) {
          password = (_ref = message.ext) != null ? _ref.password : void 0;
          if (password !== secret) {
            if (debug) {
              console.log("bad password: " + password);
            }
            message.error = '403::Password required';
          } else {
            if (debug) {
              console.log("message received", message);
            }
          }
        }
        callback(message);
      },
      outgoing: function(message, callback) {
        if (message.ext) {
          delete message.ext.password;
        }
        callback(message);
      }
    });
  }

  run = function() {
    var client, n;
    console.log("starting server on port " + pusherPort);
    bayeux.attach(server);
    server.listen(pusherPort);
    bayeux.on('subscribe', function(clientId, channel) {
      console.log("[SUBSCRIBE] " + clientId + " -> " + channel);
    });
    console.log("subscribing to http://" + pusherHost + ":" + pusherPort + "/public");
    client = new faye.Client("http://" + pusherHost + ":" + pusherPort + "/public");
    n = 0;
    return setInterval(function() {
      var res;
      res = client.publish('/tick', {
        ts: Date.now()
      });
      if (debug) {
        console.log("sending tick " + (Date.now()), res);
      }
    }, 30000);
  };

  figlet.text('Tokenly Pusher', 'Slant', function(err, data) {
    process.stdout.write(data + "\n\n");
  });

  setTimeout(function() {
    return run();
  }, 10);

}).call(this);
