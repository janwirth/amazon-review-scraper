    cheerio = require 'cheerio'
    request = require 'request'
    Promise = require 'bluebird'
    fs      = require 'fs'

    r = Promise.promisify request

    PageSelector = require './PageSelector'
    pageSelector = new PageSelector()

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

            # required fields
            title = $($(el).find('.review-title')[0]).text()
            rating = parseInt $($(el).find('.review-rating ')[0]).text().substr 0,1
            dateArray = $(el.children[2].children[3]).text().split ' '
            date = new Date $($(el).find('.review-date')[0]).text().split('on ')[1]
            text = $($(el).find('.review-text')[0]).text()

            # optional fields
            getVotes = (el) ->
                votes =
                    helpful: 0
                    total: 0
                votesEl = $(el).find('.review-votes')[0]
                if votesEl?
                    votesText = $(votesEl).text()
                    votesTextSegments = votesText.split ' of '
                    votes.helpful = parseInt votesTextSegments[0].replace(/,/g, '')
                    votes.total = parseInt votesTextSegments[1].split(' people')[0].replace(/,/g, '')
                votes
            votes = getVotes(el)

            getComments = (el) ->
                commentCount = 0
                commentsEl = $(el).find('.review-comment-total')[0]
                if commentsEl?
                    commentCount = parseInt $(commentsEl).text()
                commentCount
            commentCount = getComments(el)

            # reviewer badges: vine, top1000 or top500
            badges = {}

            for rankRange in [10, 50, 100, 500, 1000]
                # push rank when element is found
                badges['top' + rankRange] = $(el).find('.c7y-badge-top-' + rankRange + '-reviewer')[0]?

            for specialbadge in ['hall-of-fame', 'vine-voice']
                badges[specialbadge] = $(el).find('.c7y-badge-' + specialbadge )[0]?

            # check is reviewed purchase is verified
            verified = $($(el).find('.review-data')[0].children[2]).text() == 'Verified Purchase'

            #  count images
            images = $($(el).find('.review-image-tile-section')[0])['0']
            if images?
                imageCount = 0
                for image in images.children
                    imageCount++ if image.attribs.src? if image.attribs?
            else
                imageCount = 0

            reviewData =
                id: reviewElement.attribs.id
                productId: amazonProductId
                rating: rating
                date: date

                title: title
                text: text

                verified: verified
                badges: badges
                imageCount: imageCount
                votes: votes
                commentCount: commentCount

            return reviewData









        # returns all review information of a given product, identified by URL
        scrapeProductReviews: (productUrl, opts) =>
            pageSelector.getPageUrls(productUrl, opts)
                .then (urls) => @scrapeProductReviewPages(urls, productUrl)
                .then (data) => new Promise (resolve) => resolve data


        scrapeProduct: (productUrl) =>
            new Promise (resolve) =>
                amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]
                departmentId = /zg_bs_(.*?)_/.exec(productUrl)
                if departmentId?
                    departmentId = departmentId[1]

                r {uri: productUrl}
                    .then (res, body) ->
                        $ = cheerio.load res.body
                        price = Number $('#priceblock_ourprice').text().substr(1)
                        avgRating = Number $('#avgRating span a span').text().trim().substr(0,3)
                        productData =
                            name: $('#productTitle').text()
                            id: amazonProductId
                            departmentId: departmentId
                            price: price
                            avgRating: avgRating
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
            r {uri: departmentUrl}
                .then (res, body) ->
                    $ = cheerio.load res.body

                    productUrls = []

                    linkQuery = $ '.zg_title a'
                    new Promise (resolve) ->
                        linkQuery.each (i, elem)->
                            productUrl = elem.attribs.href
                            productUrls[i] = productUrl.replace(/(\r\n|\n|\r)/gm,"") if i < maxProducts
                        resolve productUrls

        scrapeDepartmentProducts: (departmentUrl, maxProducts, opts) =>
            @getDepartmentProductUrls(departmentUrl, maxProducts).then (urls) =>
                departmentRequests = []

                for productUrl in urls
                    productRequest = pageSelector.getPageUrls(productUrl, opts)
                        .then (urls) => @scrapeProductReviewPages(urls, productUrl)
                        .then (data) => new Promise (resolve) => resolve data
                    departmentRequests.push productRequest 

                Promise.all(departmentRequests).then (responses) =>
                    new Promise (resolve) =>
                        productDatasets = []
                        for datasetSet in responses
                            productDatasets = productDatasets.concat datasetSet
                        resolve productDatasets

    module.exports = AmazonReviewScraper