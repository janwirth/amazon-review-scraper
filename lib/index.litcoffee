Acquire external dependencies

    request = require 'request'
    Promise = require 'bluebird'
    fs      = require 'fs'

Promisification is leveraged to simplify the usage of
all the asynchronous operations performed.
Bluebird allows to wait for multiple async operations to complete.

    r = Promise.promisify request

Require in instantiate internal modules.

    PageSelector = require './PageSelector'
    Scraper      = require './Scraper'
    pageSelector = new PageSelector()
    scraper      = new Scraper()

# Amazon Scraper
This node module allows us to scrape content off Amazon in bulk.
Currently this is only tested with amazon.com.
Construct without parameters.

    class AmazonScraper

Resolves product information and reviews of a given product, identified by URL.

        scrapeProductReviews: (productUrl, opts) =>
            pageSelector.getPageUrls(productUrl, opts)
                .then (urls) => @scrapeProductReviewPages(urls, productUrl)


Gets only product information by given URL.

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

Scrape all reviews of a review page, identified by URL.

        scrapeProductReviewPages: (urlsToScrape, productUrl) =>
            pageRequests = []
            amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]

Push all request promises into an array.

            for url in urlsToScrape
                pageRequests.push r {uri: url}

Wait for all Promises to resolve and scrape reviews off pages in the responses.

            new Promise (resolve) =>
                productReviewDatasets = []
                Promise.all(pageRequests).then (responses) =>
                    for res in responses
                        productReviewDatasets = productReviewDatasets.concat scraper.scrape(res.body, 'reviewPage', {amazonProductId: amazonProductId})
                    resolve productReviewDatasets


Get all data from a department beststellers page

        scrapeDepartmentBestsellers: (departmentUrl) =>
            r {uri: departmentUrl}
                .then (res, body) ->
                    new Promise (resolve) ->
                        resolve scraper.scrape(res.body, 'departmentBestsellers')


Scrape all reviews with product off a department

        scrapeDepartmentProducts: (departmentUrl, pageSelectionOpts) =>
            @scrapeDepartmentBestsellers(departmentUrl).then (data) =>
                productReviewRequests = []

start requests for all product reviews

                for productUrl in data.productUrls
                    productRequest = pageSelector.getPageUrls(productUrl, pageSelectionOpts)
                        .then (urls) => @scrapeProductReviewPages(urls, productUrl)
                    productReviewRequests.push productRequest

                Promise.all(productReviewRequests).then (responses) =>
                    new Promise (resolve) =>
                        productDatasets = []
                        for datasetSet in responses
                            productDatasets = productDatasets.concat datasetSet
                        resolve productDatasets

    module.exports = AmazonScraper
