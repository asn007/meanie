express   = require 'express'
fs        = require 'fs'
config    = require '../../config'
mongoose  = require 'mongoose'
router    = express.Router();

Page = mongoose.model 'Page'

router.get '/', (req, res, next) ->
  Page.find({}).exec (err, pages) ->
    if err or not pages
      res.status 500
      return res.json { message: 'Server error. Try again later' }
    resarr = []
    for page in pages
      resarr.push page.__short()
    res.json resarr

router.get '/:id', (req, res, next) ->
  Page.findById(req.params.id).exec (err, page) ->
    if err
      res.status 500
      return res.json { message: 'Server error. Try again later' }
    if not page
      res.status 404
      return res.json { message: 'Page not found'}
    res.json page

module.exports = router;
module.exports.bootstrap_path = '/ajax/pages'