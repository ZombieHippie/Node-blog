module.exports = (collection,db)->
	db.model 'Player',\
	{name: String, online: Boolean, hash: String, salt: String, last_seen: Date, last_words: String},\
	collection