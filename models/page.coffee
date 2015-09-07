mongoose      = require 'mongoose'

Schema        = mongoose.Schema

PageSchema = new Schema {
  title: String
  text: String
}

mongoose.model 'Page', PageSchema