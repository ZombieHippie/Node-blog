connect = require('connect')
express = require('express')
http = require('http')
mongoose = require('mongoose')
async = require 'async'
port = process.env.PORT || 8082

# Setup MongoDB
mongoose.connect 'mongodb://localhost/blog'

Post = mongoose.model 'Post', {title: String, content: String, date: Date}

# Setup Express
server = express()
server.configure ()->
	server.set('views', __dirname + '/views')
	server.set('view options', { layout: false })
	server.use(express.bodyParser()) #parses json, multi-part (file), url-encoded
	server.use(express.cookieParser())
	server.use(express.session({ secret: "shhhhhhhhh!"}))
	server.use(connect.static(__dirname + '/static'))
	server.use(server.router) #need to be explicit, (automatically adds it if you forget)
	server.locals.pretty = true;


#setup the errors
# This doesn't do anything yet because of changes in express
error = (err, req, res, next)->
		if (err instanceof NotFound)
			res.render '404.jade', {
					title: '404 - Not Found'
					description: ''
					author: ''
					analyticssiteid: 'XXXXXXX'}
		else
			res.render '500.jade', {
					title: 'The Server Encountered an Error'
					description: ''
					author: ''
					analyticssiteid: 'XXXXXXX'
					error: err}


#///////////////////////////////////////////
#//              Routes                   //
#///////////////////////////////////////////

#/////// ADD ALL YOUR ROUTES HERE  /////////

server.get '/blog/action/post', (req, res) ->
	req.query['date'] = new Date()
	newPost = new Post(req.query)
	newPost.save((err)->
		if(err)
			res.redirect '/500'
		else
			res.redirect '/'	
	)

server.get '/blog/write', (req,res) ->
	res.render 'newpost.jade', {
			title: 'Write new post'
			description: 'Write a post for the node-blog'
			author: 'Cole R Lawrence'
			analyticssiteid: 'XXXXXXX'
			sessionCookie: req.sessionID}

server.get '/', (req,res) ->
	postq = Post.find {}
	postq.limit '10'
	postq.sort '-date'
	postq.exec().addCallback (success) =>
		res.render 'blog.jade', {
			title: 'Blog'
			description: 'Your Page Description'
			author: 'Cole R Lawrence'
			analyticssiteid: 'XXXXXXX'
			sessionCookie: req.sessionID
			posts:success}


#A Route for Creating a 500 Error (Useful to keep around)
server.get '/500', (req, res) ->
		throw new Error('This is a 500 Error')

NotFound = (msg)->
		this.name = 'NotFound'
		Error.call(this, msg)
		Error.captureStackTrace(this, arguments.callee)

server.listen(port)

console.log("Web server listening on port " + port)