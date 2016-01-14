cheerio = require 'cheerio'
request = require 'request'
Promise = require 'bluebird'
fs      = require 'fs'

r = Promise.promisify request

# ToDo Features

## required:
## implement options: page sets, minimum review count; department URL

## optional:
## Create documentation with codo
## change IP through TOR and/or chunk pages to prevent DDoS denial
## scrape complete review comments
## Implement constructor options for domain



# ToDo Refactors:

## extract page count finder / page identification
## reorder methods by call order
## chain promised methods
## refactor single review extractor with selectors?? performance- readbility+ ?

class AmazonReviewScraper

    domainUrl: 'http://www.amazon.com'
    productReviewsBaseUrl: '/product-reviews/'

    departments: [
        '/Best-Sellers-Electronics/zgbs/electronics/'
        '/Best-Sellers-Automotive/zgbs/automotive/'
        '/Best-Sellers-Grocery-Gourmet-Food/zgbs/grocery/'
        ]




    # SYNCHRONOUS

    # scrapes all reviews displayed on a single paginated set of reviews, e.g. a page
    scrapeProductReviewPage: (body, amazonProductId) =>
        $ = cheerio.load body
        reviewDataSets = []
        reviews = $ '#cm_cr-review_list > .a-section'
            .each (i, el) =>
                reviewDataSets.push @scrapeSingleReview $, el, amazonProductId
        return reviewDataSets

    # scrapes all information off a single review DOM element
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

    # Current: returns all review information of a given product, identified by URL
    scrapeProductReviews: (productUrl)=>
        amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]

        # get total page count
        r {uri: @domainUrl + @productReviewsBaseUrl + amazonProductId}
            .then (res) =>
                ## Extract this: getPagesToScrape (by set & review count per page)
                ## request base page and get review count aswell as total pages count
                ## Expect last page to yield minimum 1 review
                ## select set by identifier and minimum review count
                ## prevent unnecessary request through recycling response for first page extraction???
                $ = cheerio.load res.body
                pagination = $ '.a-pagination'
                lastPageLink = pagination[0].children[pagination[0].children.length - 2].children[0]
                totalReviewPageCount = lastPageLink.attribs.href.split('pageNumber=')[1]

                pageRequests = []

                # create request array with sane defaults
                for pageNumber in [1 .. 2]
                    pageRequests.push r {uri: @domainUrl + @productReviewsBaseUrl + amazonProductId + '?pageNumber=' + pageNumber}

                # scrape reviews off pages in responses
                new Promise (resolve) =>
                    productReviewDatasets = []
                    Promise.all(pageRequests).then (responses) =>
                        for res in responses
                            productReviewDatasets = productReviewDatasets.concat @scrapeProductReviewPage(res.body, amazonProductId)
                        resolve productReviewDatasets


    # get product URLS of department bestsellers
    getDepartmentProductUrls: (departmentUrl) =>
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
