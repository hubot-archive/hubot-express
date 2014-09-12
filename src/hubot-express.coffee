module.exports = (robot) ->
  express = require 'express'
  cookieParser = require 'cookie-parser'
  session = require 'express-session'

  robot.express = app = express()

  user = process.env.EXPRESS_USER
  pass = process.env.EXPRESS_PASSWORD
  stat = process.env.EXPRESS_STATIC

  sessionOptions =
    secret: robot.name + Date.now()

  app.use (req, res, next) =>
    res.setHeader "X-Powered-By", "hubot/#{robot.name}"
    next()

  app.use express.basicAuth user, pass if user and pass
  app.use express.query()
  app.use express.bodyParser()
  app.use cookieParser()
  app.use session sessionOptions
  app.use express.static Path.normalize("#{__dirname}/#{stat}") if stat

  # give scripts an opportunity to modify the express app before starting the server
  robot.emit 'express-loaded', @
  @loaded = true

  @init = (port, bindAddress) =>
    if !@initialized
      try
        @server = app.listen(port || process.env.PORT || 8080, bindAddress || process.env.BIND_ADDRESS || '0.0.0.0')
        @router = app
        @initialized = true
      catch err
        robot.logger.error "Error trying to start HTTP server: #{err}\n#{err.stack}"
        process.exit(1)

    @
