cheerio = require 'cheerio'
request = require 'request'
Promise = require 'bluebird'
fs      = require 'fs'

r = Promise.promisify request

class AmazonReviewScraper

    domainUrl: 'http://www.amazon.com'
    productReviewsBaseUrl: '/product-reviews/'

    departments: [
        '/Best-Sellers-Electronics/zgbs/electronics/'
        '/Best-Sellers-Automotive/zgbs/automotive/'
        '/Best-Sellers-Grocery-Gourmet-Food/zgbs/grocery/'
        ]

    # SYNCHRONOUS

    scrapeProductReviewPage: (body, amazonProductId) =>
        $ = cheerio.load body
        reviewDataSets = []
        reviews = $ '#cm_cr-review_list > .a-section'
            .each (i, el) =>
                reviewDataSets.push @scrapeSingleReview $, el, amazonProductId
        return reviewDataSets

    scrapeSingleReview: ($, el, amazonProductId) =>
        reviewElement = el

        titleArray = $(el.children[1])
        title = $(titleArray[0].children[2]).text()

        dateArray = $(el.children[2].children[3]).text().split ' '

        votesArray = $(el.children[0]).text().split ' '
        commentCount = $($(el).find('.review-comment-total')[0]).text()
        text = $($(el).find('.review-text')[0]).text()

        reviewData =
            id: reviewElement.attribs.id
            productId: amazonProductId
            date: dateArray[3].concat(' ', dateArray[1],' ' , dateArray[2].split(',')[0])

            rating: titleArray.text().split('.')[0]
            title: title
            text: text

            votes:
                helpful: votesArray[0]
                total: votesArray[2]
            comments:
                count: commentCount

        return reviewData




    # ASYNCHRONOUS

    scrapeProductReviews: (productUrl)=>
        amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]

        # get total page count
        r {uri: @domainUrl + @productReviewsBaseUrl + amazonProductId}
            .then (res) =>
                $ = cheerio.load res.body
                pagination = $ '.a-pagination'
                lastPageLink = pagination[0].children[pagination[0].children.length - 2].children[0]
                totalReviewPageCount = lastPageLink.attribs.href.split('pageNumber=')[1]

                # ToDo: chunk pages to prevent DDoS denial
                # ToDo: pass param to identify page sets to scrape
                # ToDo: Chain these Promised functions into one clean metho

                # too much: for pageNumber in [1 .. totalReviewPageCount]
                pageRequests = []

                for pageNumber in [1 .. 2]
                    pageRequests.push r {uri: @domainUrl + @productReviewsBaseUrl + amazonProductId + '?pageNumber=' + pageNumber}

                new Promise (resolve) =>
                    productReviewDatasets = []
                    Promise.all(pageRequests).then (responses) =>
                        for res in responses
                            productReviewDatasets = productReviewDatasets.concat @scrapeProductReviewPage(res.body, amazonProductId)
                        resolve productReviewDatasets

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

module.exports = AmazonReviewScraper
