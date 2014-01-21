connect = require 'connect'
express = require 'express'
http = require 'http'
mongoose = require 'mongoose'
devreload = require 'devreload'
port = process.env.PORT || 8082

# Use devreload for automatic reloading in devstate
devreload.run {watch:[__dirname], interval:500, port:3001}

# Setup MongoDB
mongoose.connect 'mongodb://localhost/blog'

# Setup Express
server = express()

server.set('views', __dirname + '/views')
server.set('view options', { layout: false })

server.use(express.bodyParser()) #parses json, multi-part (file), url-encoded
server.use(express.cookieParser('the truth')) #parses session cookies
server.use(express.session())

server.use(connect.static(__dirname + '/static'))
server.use(server.router) #need to be explicit, (automatically adds it if you forget)
server.locals.pretty = true; # Pretty output from jade




#///////////////////////////////////////////
#//              Routes                   //
#///////////////////////////////////////////


login = require './routes/login'
login.setDB mongoose
server.all '/blog/login', login.login
server.all '/blog/register', login.register
server.all '/blog/logout', login.logout

blog = require './routes/blog'
blog.setDB mongoose
server.all '/blog/write', blog.write
server.all '/blog', blog.list

server.all '/', (req,res) ->
	console.log req
	res.redirect '/blog'


#A Route for Creating a 500 Error (Useful to keep around)
server.all '/500', (req, res) ->
		throw new Error('This is a 500 Error')

NotFound = (msg)->
		this.name = 'NotFound'
		Error.call(this, msg)
		Error.captureStackTrace(this, arguments.callee)

server.listen(port)

console.log("Web server listening on port " + port)