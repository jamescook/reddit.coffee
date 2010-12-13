# Experimental library for talking to Reddit's JSON apis.
# Relies on a tweak to reddit's codebase allowing cross origin requests.
# config/middleware.py: https://gist.github.com/737707
# 
# Requirements: jQuery, underscore.js, & coffeescript to compile the below code.
class Reddit
  constructor: (@options) ->
    @options    = @parse_options(@options)
    @login      = @options["login"]
    @password   = @options["password"]
    jQuery.ajaxSetup({async:false, timeout: 10000})

  domain: ->
    @config("domain") or "reddit.com"

  parse_options: (opts) =>
    if opts and typeof(opts) isnt "object"
      opts = {}
    opts

  json: (url, kind=RedditListing) ->
    data   = jQuery.getJSON url
    proper = jQuery.parseJSON data.responseText
    new kind(proper)

  config: (key, val) ->
    if key? and val?
      @options[key] = val
      @options[key]
    else
      @options[key]
    
  browse: (subreddit) ->
    _json = @json("http://" + @domain() + "/r/" + subreddit + ".json")
       
  user: (user) ->
    _json = @json("http://" + @domain() + "/user/" + user + "/about.json", RedditUser)

  # Note: Due to the way authentication is handled, you won't be able to get the cookie needed for actions such as voting unless
  # you authenticate inside reddit.com. In other words, if you reddit.authenticate() from foo.com, reddit will send back the cookie
  # but your code won't have access to it. Yeah, it sucks.
  authenticate: () ->
    _url = "http://" + @domain() + "/api/login/.json"
    jQuery.ajax(
      async: true,
      global: false,
      url:  _url,
      type: "POST",
      data: {"user": @config("login"), "passwd": @config("password")}
    )

class RedditThing
  constructor: (json) ->
    @detail = {}
    @parse(json.data)

  get: (key) ->
    @detail[key]

  parse: (json) ->
    _.each( json, (val, key) =>
      @detail[key] = val
    )
    @detail

class RedditUser extends RedditThing
  friend: ->
  unfriend: ->

class RedditSubmission extends RedditThing
  upvote: ->
  downvote: ->

class RedditListing
  constructor: (json) ->
    @parse(json)
  
  parse: (json) ->
    @things = []
    data   = json.data
    _.each( data.children, (thing, i) =>
           @things.push( new RedditSubmission(thing) )
    )
    @things

