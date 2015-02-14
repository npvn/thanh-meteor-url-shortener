Meteor.methods 
  urlInsert: (urlInput) ->
    check urlInput, 
      longUrl: String
      customUrl: Match.Optional(String)
      isPrivate: Boolean
      _id: Match.Optional(String)
      author: Match.Optional(String)

    shortUrlExists = (newShortUrl, _id)->
      if _id
        !!UrlList.find
                    _id: $ne: _id
                    shortUrl: newShortUrl
                 .fetch().length
      else
        !!UrlList.find
                    shortUrl: newShortUrl
                  .fetch().length

    makeUniqueShortUrl = ->
      randomShortUrl = Random.id 5
      while shortUrlExists randomShortUrl
        randomShortUrl = Random.id 5
      randomShortUrl

    Helpers.validateLongUrl urlInput.longUrl

    if urlInput.customUrl
      Helpers.validateCustomUrl urlInput.customUrl

    if urlInput._id and urlInput.author
      if (UrlList.findOne _id: urlInput._id)?.author is urlInput.author
        
        if not urlInput.customUrl
          throw new Meteor.Error 'emptyShortUrl', 'Your ShortUrl must not be empty!'
        
        if shortUrlExists urlInput.customUrl, urlInput._id
          throw new Meteor.Error 'shortUrlExists', 'Your short link has existed!'
        
        UrlList.update {_id: urlInput._id},
          $set: 
            longUrl: urlInput.longUrl
            shortUrl: urlInput.customUrl
            isPrivate: urlInput.isPrivate
      else
        throw new Meteor.Error 'rightAuthor', 'You are not the author of this URL!'
    else
      if not urlInput.customUrl
        shortUrl = makeUniqueShortUrl()
      
      else
        if shortUrlExists urlInput.customUrl
          throw new Meteor.Error 'shortUrlExists', 'Your custom link ' + 
          'has already existed! Please try another one.'
        shortUrl = urlInput.customUrl

      UrlList.insert 
        longUrl: urlInput.longUrl
        shortUrl: shortUrl
        author: Meteor.userId()
        isPrivate: urlInput.isPrivate
        accessedUrlCount: 0
   