#Database
Post = null
exports.setDB = (mongoose)->
	Post = require('../models/Post.coffee')('postdata', mongoose)

exports.write = (req,res) ->
	switch req.method
		when 'GET'
			res.render 'newpost.jade', {
					title: 'Write new post'
					user: req.session.user}
		when 'POST'
			q = {
				title : req.body.title
				content : req.body.content
				user : req.session.user.name
				date : new Date()
			}
			if(q.title and q.content)
				newPost = new Post(q)
				newPost.save (err)->
					console.log {err}
					if(err)
						res.redirect '/500'
					else
						res.redirect '/blog'
			else
				console.log 
				res.redirect '/500'

exports.list = (req,res) ->
	console.log req.session
	postq = Post.find {}
	postq.limit '10'
	postq.sort '-date'
	postq.exec().addCallback (success) =>
		res.render 'blog.jade', {
			title: '=INKBLUR='
			analyticssiteid: 'XXXXXXX'
			posts:success
			user: req.session.user}