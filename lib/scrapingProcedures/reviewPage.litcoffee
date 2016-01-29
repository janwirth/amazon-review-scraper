    scrapeReview = require './review'
    cheerio      = require 'cheerio'

Scrape a single page from a paginated set of reviews

    module.exports = (body, amazonProductId) =>
        $ = cheerio.load body
        reviewDataSets = []
        reviews = $ '#cm_cr-review_list > .a-section'
            .each (i, el) =>
                reviewDataSets.push scrapeReview $, el, amazonProductId
        return reviewDataSets
