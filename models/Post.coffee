module.exports = (collection,db)->
	db.model 'Post',\
	{title: String, content: String, date: Date, user: String, comments: Array},\
	collection