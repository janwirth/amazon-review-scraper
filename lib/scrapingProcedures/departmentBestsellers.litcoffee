    cheerio = require 'cheerio'
    _       = require 'lodash'

    module.exports = (body) ->
        $ = cheerio.load body
        departmentData =
            productUrls: []
        linkQuery = $ '.zg_title a'
        linkQuery.each (i, elem)->
            productUrl = elem.attribs.href
            departmentData.productUrls[i] = productUrl.replace(/(\r\n|\n|\r)/gm,"")
        return departmentData
