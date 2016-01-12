cheerio = require 'cheerio'
request = require 'request'
Promise = require 'bluebird'
fs      = require 'fs'

r = Promise.promisify request

class AmazonReviewScraper

    domainUrl: 'http://www.amazon.com'
    productReviewsBaseUrl: '/product-reviews/'

    config:
        maxProducts: 10
        maxReviews: 10

    departments: [
        '/Best-Sellers-Electronics/zgbs/electronics/'
        '/Best-Sellers-Automotive/zgbs/automotive/'
        '/Best-Sellers-Grocery-Gourmet-Food/zgbs/grocery/'
        ]

    constructor: (@domain) ->




    crawlProduct: () ->

    scrapeProductReviewPage: (body) =>
        $ = cheerio.load body
        reviews = $ '#cm_cr-review_list > .a-section'
            .each ->
                console.log '__________________________________'
                console.log $(this).text()
        linkNextPage = $ '.a-last'
            .each (i, el) =>
                console.log 'next page __________________________________'
                nextPageUrl = $(el).children()[0].attribs.href
                if nextPageUrl?
                    r({uri: @domainUrl + nextPageUrl})
                        .then (res, body) =>
                            @scrapeProductReviewPage(res.body)

    scrapeReviewMetaData: (reviewId)->

    scrapeProductReviews: (productUrl, maxReviews)=>
        amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]

        r {uri: @domainUrl + @productReviewsBaseUrl + amazonProductId}
            .then (res, body) =>
                @scrapeProductReviewPage(res.body)

    getDepartmentProductUrls: (departmentUrl, maxProducts) =>
        r {uri: @domainUrl + @departments[0]}
            .then (res, body) ->
                $ = cheerio.load res.body

                productUrls = []

                linkQuery = $ '.zg_title a'
                new Promise (resolve) ->

                    linkQuery.each (i, elem)->
                        productUrl = elem.attribs.href
                        productUrls[i] = productUrl.replace(/(\r\n|\n|\r)/gm,"") if i < maxProducts
                    resolve productUrls

#    scrapeProductMetaData: ->




module.exports = AmazonReviewScraper
