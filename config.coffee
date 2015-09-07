development   = require './config/development.json'
production    = require './config/development.json'

if process.env.APP_ENV and process.env.APP_ENV == 'production'
  module.exports = production
  module.exports.env = 'production'
else
  module.exports = development
  module.exports.env = 'development'