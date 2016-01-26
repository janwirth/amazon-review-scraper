cheerio = require 'cheerio'
request = require 'request'
Promise = require 'bluebird'
fs      = require 'fs'

r = Promise.promisify request

# ToDo Features

## required:
## implement options: page sets, minimum review count; department URL

## optional:
## extend options, remove hard-coded options, use underscore?
## Create documentation with codo
## change IP through TOR and/or chunk pages to prevent DDoS denial
## scrape complete review comments
## Implement constructor options for domain



# ToDo Refactors:
## extract scrapeSingleReview
## chain promised methods
## refactor single review extractor with selectors?? performance- readbility+ ?

class AmazonReviewScraper

    domainUrl: 'http://www.amazon.com'
    productReviewsBaseUrl: '/product-reviews/'

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

    getPagesToScrape: (productUrl, opts) =>
        amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]

        # get total page count
        if !opts? || !opts.pageChunks?
            pageChunks =
                start: 3
                middle: 0
                end: 0
        else
            pageChunks = opts.pageChunks

        if !opts? || !opts.sortOrder?
            sortOrder = 'helpful'
        else
            sortOrder = opts.sortOrder

        r {uri: @domainUrl + @productReviewsBaseUrl + amazonProductId}
            .then (res) =>
                new Promise (resolve) =>
                    ## Extract this: getPagesToScrape (by set & review count per page)
                    ## request base page and get review count aswell as total pages count
                    ## Expect last page to yield minimum 1 review
                    ## select set by identifier and minimum review count
                    ## prevent unnecessary request through recycling response for first page extraction???
                    $ = cheerio.load res.body
                    pagination = $ '.a-pagination'
                    lastPageLink = pagination[0].children[pagination[0].children.length - 2].children[0]
                    totalReviewPageCount = lastPageLink.attribs.href.split('pageNumber=')[1]
                    pageNumbersToScrape = [1 .. totalReviewPageCount]
                    if (pageChunks.start && pageChunks.middle && pageChunks.end) <= totalReviewPageCount
                        start = pageNumbersToScrape.slice 0, pageChunks.start
                        end = pageNumbersToScrape.slice pageNumbersToScrape.length - pageChunks.end, pageNumbersToScrape.length
                        middleStartIndex = Math.round (pageNumbersToScrape.length - pageChunks.middle) / 2
                        middle = pageNumbersToScrape.slice middleStartIndex, middleStartIndex + pageChunks.middle
                        pageNumbersToScrape = start.concat middle, end
                        # filter duplicates
                        pageNumbersToScrape = pageNumbersToScrape.filter (item, pos) ->
                            pageNumbersToScrape.indexOf(item) == pos
                    pagesToScrape = []
                    # build url
                    for pageNumber in pageNumbersToScrape
                        pageUrl = @domainUrl + @productReviewsBaseUrl + amazonProductId + '?pageNumber=' + pageNumber + '&sortBy=' + sortOrder
                        pagesToScrape.push pageUrl
                    resolve pagesToScrape




    # returns all review information of a given product, identified by URL
    scrapeProductReviews: (productUrl, opts) =>
        @getPagesToScrape(productUrl, opts)
            .then (urls) => @scrapeProductReviewPages(urls, productUrl)
            .then (data) => new Promise (resolve) => resolve data


    scrapeProduct: (productUrl) =>
        new Promise (resolve) =>
            amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]
            r {uri: productUrl}
                .then (res, body) ->
                    $ = cheerio.load res.body
                    price = Number $('#priceblock_ourprice').text().substr(1)
                    productData =
                        name: $('#productTitle').text()
                        id: amazonProductId
                        price: price
                    resolve productData

    # scrapes all review page urls
    scrapeProductReviewPages: (urlsToScrape, productUrl) =>
        pageRequests = []
        amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]
        # create request array with sane defaults
        for url in urlsToScrape
            pageRequests.push r {uri: url}

        # scrape reviews off pages in responses
        new Promise (resolve) =>
            productReviewDatasets = []
            Promise.all(pageRequests).then (responses) =>
                for res in responses
                    productReviewDatasets = productReviewDatasets.concat @scrapeProductReviewPage(res.body, amazonProductId)
                resolve productReviewDatasets


    # get product URLS of department bestsellers
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
