express   = require 'express'
router    = express.Router();


# Partials renderer

router.get '/*', (req, res, next) ->
  res.render "partials#{req.path.replace '..', '.'}"

module.exports = router;
module.exports.bootstrap_path = '/partials'