(function(){var e,t,n,r,o,c,i;c=process.env.PUSHER_PORT||8200,r=require("http"),n=require("faye"),i=r.createServer(),e=new n.NodeAdapter({mount:"/public"}),console.log("starting server on port "+c),e.attach(i),i.listen(c),e.on("subscribe",function(e,t){return console.log("[SUBSCRIBE] "+e+" -> "+t)}),t=new n.Client("http://localhost:"+c+"/public"),o=0,setInterval(function(){return t.publish("/tick",{ts:Date.now()})},3e4)}).call(this);