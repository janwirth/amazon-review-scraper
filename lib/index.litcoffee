    request = require 'request'
    Promise = require 'bluebird'
    fs      = require 'fs'

    r = Promise.promisify request

    PageSelector = require './PageSelector'
    Scraper      = require './Scraper'
    pageSelector = new PageSelector()
    scraper      = new Scraper()

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
        # returns all review information of a given product, identified by URL
        scrapeProductReviews: (productUrl, opts) =>
            pageSelector.getPageUrls(productUrl, opts)
                .then (urls) => @scrapeProductReviewPages(urls, productUrl)
                .then (data) => new Promise (resolve) => resolve data


        scrapeProduct: (productUrl) =>
            new Promise (resolve) =>
                context = {}
                context.amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]
                context.departmentId = /zg_bs_(.*?)_/.exec(productUrl)
                if context.departmentId?
                    context.departmentId = context.departmentId[1]

                r {uri: productUrl}
                    .then (res, body) ->
                        resolve scraper.scrape res.body, 'product', context

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
                        productReviewDatasets = productReviewDatasets.concat scraper.scrape(res.body, 'reviewPage', {amazonProductId: amazonProductId})
                    resolve productReviewDatasets


        # get product URLS of department bestsellers
        getDepartmentProductUrls: (departmentUrl, maxProducts) =>
            r {uri: departmentUrl}
                .then (res, body) ->
                    new Promise (resolve) ->
                        resolve scraper.scrape(res.body, 'departmentBestsellers').productUrls

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
