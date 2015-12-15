cheerio = require 'cheerio'
request = require 'request'
promise = require 'bluebird'
fs      = require 'fs'



class AmazonReviewScraper
    domain = 'http://www.amazon.de'
    reviewUrl = '/product-reviews/B013WVOAIG/'

    crawlComments = (err, res, body) ->
        $ = cheerio.load body
        reviews = $ '#cm_cr-review_list > .a-section'
            .each ->
                # console.log $(this).text()
        linkNextPage = $ '.a-last'
            .each ->
                console.log '__________________________________'
                nextPageUrl = $(this).children()[0].attribs.href
                console.log domain + nextPageUrl
                console.log domain + reviewUrl
                request({uri: domain + nextPageUrl}, crawlComments) if nextPageUrl?

    request {uri: domain + reviewUrl}, crawlComments


module.exports = AmazonReviewScraper
