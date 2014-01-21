hash = require('../pass').hash
#Database
Player = null
exports.setDB = (mongoose)->
	Player = require('../models/Player.coffee')('playerdata', mongoose)

exports.login = (req, res)->
	switch req.method
		when 'GET'
			res.render 'login.jade', {
					title: 'Log in'
					user: req.session.user}
		when 'POST'
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

exports.register = (req,res) ->
	switch req.method
		when 'GET'
			res.render 'register.jade', {
					title: 'Register'
					user: req.session.user}
		when 'POST'
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

exports.logout = (req, res)->
	# destroy the user's session to log them out
	# will be re-created next request
	req.session.destroy ->
		res.redirect('/')

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