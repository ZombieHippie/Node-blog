connect = require('connect')
express = require('express')
http = require('http')
mongoose = require('mongoose')
devreload = require 'devreload'
hash = require('./pass').hash
port = process.env.PORT || 8082

# Use devreload for automatic reloading in devstate
devreload.run {watch:[__dirname], interval:500, port:3001}

# Setup MongoDB
mongoose.connect 'mongodb://localhost/blog'

# Setup Express
server = express()

Post = require('./models/Post.coffee')('postsdata', mongoose)
Player = require('./models/Player.coffee')('playerdata', mongoose)

server.set('views', __dirname + '/views')
server.set('view options', { layout: false })

server.use(express.bodyParser()) #parses json, multi-part (file), url-encoded
server.use(express.cookieParser('the truth')) #parses session cookies
server.use(express.session())

server.use(connect.static(__dirname + '/static'))
server.use(server.router) #need to be explicit, (automatically adds it if you forget)
server.locals.pretty = true; # Pretty output from jade


authenticate = (name, pass, fn)->
	Player.findOne {name}, 'name salt hash', (err, player) ->
		return fn(err) if err
		# query the db for the given username
		if (!player)
			return fn(new Error('cannot find user'))
		# apply the same algorithm to the POSTed password, applying
		# the hash against the pass / salt, if there is a match we
		# found the user
		hash pass, player.salt, (err, hash) ->
			if(err)
				return fn(err)
			if(hash == player.hash)
				return fn(null, player)
			fn(new Error('invalid password'))
register = (name, pass, fn)->
	Player.findOne {name}, 'name', (err, player) ->
		return fn(err) if err
		console.log player
		# query the db for the given username
		if player
			return fn(new Error('user already registered'))
		# apply the same algorithm to the POSTed password, applying
		# the hash against the pass / salt, if there is a match we
		# found the user
		hash pass, (err, salt, hash) ->
			if(err)
				return fn(err)
			player = new Player {
				name
				hash
				salt
				online:true
			}
			player.save (err)->
				console.log "SAVE: "+name
				console.log err
				return if(err) then fn(err) else fn(null, player)


#///////////////////////////////////////////
#//              Routes                   //
#///////////////////////////////////////////

#/////// ADD ALL YOUR ROUTES HERE  /////////

server.get '/blog/write', (req,res) ->
	res.render 'newpost.jade', {
			title: 'Write new post'
			description: 'Write a post for the node-blog'
			author: 'Cole R Lawrence'
			analyticssiteid: 'XXXXXXX'
			sessionCookie: req.sessionID
			user: req.session.user}

server.post '/blog/write', (req,res) ->
	if(req.query.title? and req.query.content?)
		req.query['date'] = new Date()
		newPost = new Post(req.query)
		newPost.save (err)->
			if(err)
				res.redirect '/500'
			else
				res.redirect '/'
	else
		res.redirect '/500'

server.get '/blog/login', (req,res) ->
	res.render 'login.jade', {
			title: 'Write new post'
			description: 'Write a post for the node-blog'
			author: 'Cole R Lawrence'
			analyticssiteid: 'XXXXXXX'
			sessionCookie: req.sessionID
			user: req.session.user}

server.post '/blog/login', (req,res) ->
	authenticate req.body.username, req.body.password, (err, user)->
		if user
			console.log "User logged in:"+user.name
			# Regenerate session when signing in
			# to prevent fixation 
			req.session.regenerate ->
				console.log "Regenerate"
				# Store the user's primary key 
				# in the session store to be retrieved,
				# or in this case the entire user object
				req.session.user = user
				res.redirect('back')
		else
			res.redirect '/blog/login'


server.get '/blog/register', (req,res) ->
	res.render 'register.jade', {
			title: 'Write new post'
			description: 'Write a post for the node-blog'
			author: 'Cole R Lawrence'
			analyticssiteid: 'XXXXXXX'
			sessionCookie: req.sessionID
			user: req.session.user}

server.post '/blog/register', (req,res) ->
	register req.body.username, req.body.password, (err, user)->
		console.log {err}
		if user
			console.log "User logged in:"+user.name
			# Regenerate session when signing in
			# to prevent fixation 
			req.session.regenerate ->
				console.log "Regenerate"
				# Store the user's primary key 
				# in the session store to be retrieved,
				# or in this case the entire user object
				req.session.user = user
				res.redirect('back')
		else
			res.redirect '/blog/login'

server.get '/blog/logout', (req, res)->
	# destroy the user's session to log them out
	# will be re-created next request
	req.session.destroy ->
		res.redirect('/')

server.get '/', (req,res) ->
	console.log req.session
	postq = Post.find {}
	postq.limit '10'
	postq.sort '-post_date'
	postq.exec().addCallback (success) =>
		res.render 'players.jade', {
			title: '=INKBLUR='
			description: 'The inkblur server monitor'
			author: 'Cole R Lawrence'
			analyticssiteid: 'XXXXXXX'
			players:success
			user: req.session.user}


#A Route for Creating a 500 Error (Useful to keep around)
server.get '/500', (req, res) ->
		throw new Error('This is a 500 Error')

NotFound = (msg)->
		this.name = 'NotFound'
		Error.call(this, msg)
		Error.captureStackTrace(this, arguments.callee)

server.listen(port)

console.log("Web server listening on port " + port)