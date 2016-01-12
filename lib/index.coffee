cheerio = require 'cheerio'
request = require 'request'
Promise = require 'bluebird'
fs      = require 'fs'

r = Promise.promisify request

class AmazonReviewScraper

    domainUrl: 'http://www.amazon.com'
    reviewUrl: '/product-reviews/B00GDQ0RMG/'

    config:
        numberOfProducts: 10
        numberOfReviews: 10

    departments: [
        '/Best-Sellers-Electronics/zgbs/electronics/'
        '/Best-Sellers-Automotive/zgbs/automotive/'
        '/Best-Sellers-Grocery-Gourmet-Food/zgbs/grocery/'
        ]

    constructor: (@domain) ->




    crawlProduct = () ->

    crawlComments = (err, res, body) ->
        $ = cheerio.load body
        reviews = $ '#cm_cr-review_list > .a-section'
            .each ->
                console.log '__________________________________'
                console.log $(this).text()
        linkNextPage = $ '.a-last'
            .each ->
                console.log '__________________________________'
                nextPageUrl = $(this).children()[0].attribs.href
                console.log domain + nextPageUrl
                console.log domain + reviewUrl
                request({uri: domain + nextPageUrl}, crawlComments) if nextPageUrl?

    scrapeProduct: =>
        request {uri: @domain + reviewUrl}, crawlComments

    getDepartmentProductUrls: =>
        r {uri: @domainUrl + @departments[0]}
            .then (res, body) ->
                $ = cheerio.load res.body

                linkElementQuery = $ '.zg_title a'
                # linkElementQueryPromise = Promise.promisify linkElementQuery.each
                # linkElementQueryPromise().then ->
                #     console.log 'hi'

                linkElementQuery
                    .each ->
                        console.log '_______________'
                        productUrl = this.attribs.href
                        console.log productUrl.replace(/(\r\n|\n|\r)/gm,"")


module.exports = AmazonReviewScraper
