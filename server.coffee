connect = require('connect')
express = require('express')
http = require('http')
port = process.env.PORT || 8081

# Setup Express
server = express.createServer();
server.configure ()->
	server.set('views', __dirname + '/views')
	server.set('view options', { layout: false })
	server.use(express.bodyParser()) #parses json, multi-part (file), url-encoded
	server.use(express.cookieParser())
	server.use(express.session({ secret: "shhhhhhhhh!"}))
	server.use(connect.static(__dirname + '/static'))
	server.use(server.router) #need to be explicit, (automatically adds it if you forget)


#setup the errors
server.error (err, req, res, next)->
		if (err instanceof NotFound)
			res.render '404.jade', \
				locals:
					title: '404 - Not Found'
					description: ''
					author: ''
					analyticssiteid: 'XXXXXXX' 
				status: 404
		else
			res.render '500.jade', \
				locals:
					title: 'The Server Encountered an Error'
					description: ''
					author: ''
					analyticssiteid: 'XXXXXXX'
					error: err
				status: 500


#///////////////////////////////////////////
#//              Routes                   //
#///////////////////////////////////////////

#/////// ADD ALL YOUR ROUTES HERE  /////////

users=
	AZombiePuppie:{group:"moderator",health:"8.7"}
	AZombieHippie:{group:"admin",health:"8.7"}

forum=
	AZombiePuppie:{author:"moderator",lastpost:"8.7"}
	AZombieHippie:{author:"admin",lastpost:"8.7"}


server.get '/blog/post', (req,res) ->
	res.render 'newpost.jade', \
		locals:
			title: 'New Post'
			description: 'Your Page Description'
			author: 'Your Name'
			analyticssiteid: 'XXXXXXX'
			sessionCookie: req.sessionID

server.get '/blog', (req,res) ->
	res.render 'forum.jade', \
		locals:
			title: 'Blog'
			description: 'Your Page Description'
			author: 'Your Name'
			analyticssiteid: 'XXXXXXX'
			sessionCookie: req.sessionID
			forum:forum

server.get '/', (req,res) ->
	res.render 'index.jade', \
		locals:
			title: 'Blog'
			description: 'Your Page Description'
			author: 'Your Name'
			analyticssiteid: 'XXXXXXX'
			sessionCookie: req.sessionID
			users:users

#A Route for Creating a 500 Error (Useful to keep around)
server.get '/500', (req, res) ->
		throw new Error('This is a 500 Error')

#The 404 Route (ALWAYS Keep this as the last route)
server.get '/*', (req, res) ->
		throw new NotFound

NotFound = (msg)->
		this.name = 'NotFound'
		Error.call(this, msg)
		Error.captureStackTrace(this, arguments.callee)

server.listen(port)

console.log("Web server listening on port " + port)