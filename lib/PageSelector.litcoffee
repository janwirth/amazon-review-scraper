    _       = require 'lodash'
    Promise = require 'bluebird'
    request = require 'request'
    cheerio = require 'cheerio'
    r       =  Promise.promisify request

    module.exports = class PageSelector

        domainUrl: 'http://www.amazon.com'
        productReviewsBaseUrl: '/product-reviews/'

        algorithms:
            chunks: (totalPageCount, chunkIds) ->
                # get totalPageCount page count
                defaultChunkIds =
                    start: 3
                    middle: 0
                    end: 0
                chunkIds = _.extend defaultChunkIds, chunkIds
                pageNumbersToScrape = [1 .. totalPageCount]
                if (chunkIds.start && chunkIds.middle && chunkIds.end) <= totalPageCount
                    start = pageNumbersToScrape.slice 0, chunkIds.start
                    end = pageNumbersToScrape.slice pageNumbersToScrape.length - chunkIds.end, pageNumbersToScrape.length
                    middleStartIndex = Math.round (pageNumbersToScrape.length - chunkIds.middle) / 2
                    middle = pageNumbersToScrape.slice middleStartIndex, middleStartIndex + chunkIds.middle
                    pageNumbersToScrape = start.concat middle, end
                    # filter duplicates
                    pageNumbersToScrape = pageNumbersToScrape.filter (item, pos) ->
                        pageNumbersToScrape.indexOf(item) == pos

        getPageUrls: (productUrl, options) =>
            amazonProductId = /\/dp\/(.*?)\//.exec(productUrl)[1]

            defaults =
                sortOrder: 'helpful'
                selectionAlgorithm: 'chunks'
            options = _.extend defaults, options


            r {uri: @domainUrl + @productReviewsBaseUrl + amazonProductId}
                .then (res) =>
                    new Promise (resolve) =>
                        $ = cheerio.load res.body
                        pagination = $ '.a-pagination'
                        lastPageLink = pagination[0].children[pagination[0].children.length - 2].children[0]
                        totalReviewPageCount = lastPageLink.attribs.href.split('pageNumber=')[1]
                        pageNumbersToScrape = @algorithms[options.selectionAlgorithm] totalReviewPageCount, options.selectionAlgorithmParams
                        pagesToScrape = []
                        for pageNumber in pageNumbersToScrape
                            pageUrl = @domainUrl + @productReviewsBaseUrl + amazonProductId + '?pageNumber=' + pageNumber + '&sortBy=' + options.sortOrder
                            pagesToScrape.push pageUrl
                        resolve pagesToScrape
