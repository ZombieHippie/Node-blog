connect = require('connect')
express = require('express')
http = require('http')
path = require('path')
reload = require('reload')

publicDir = path.join(__dirname, 'public')

app = express.createServer();

app.configure ()->
  app.set('port', process.env.PORT || 3000)
  app.use(express.logger('dev'))
  server.set('views', __dirname + '/views');
  server.set('view options', { layout: false });
  server.use(express.cookieParser());

  server.use(connect.static(__dirname + '/static'));
  app.use(express.bodyParser()) #parses json, multi-part (file), url-encoded
  app.use(app.router) #need to be explicit, (automatically adds it if you forget)
  app.use(express.static(publicDir)) #should cache static assets

app.get '/', (req, res) ->
  res.render 'index.jade', locals : { 
              title : 'Your Page Title'
             ,description: 'Your Page Description'
             ,author: 'Your Name'
             ,analyticssiteid: 'XXXXXXX' 
            }

#reload code here
#reload(server, app)

app.listen app.get('port'), ()->
  console.log("Web server listening on port " + app.get('port'))