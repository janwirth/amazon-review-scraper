Scraper = require './lib/index.coffee'
AmazonComScraper = new Scraper()


# AmazonComScraper.getDepartmentProductUrls(undefined, 10).then(
#  (productUrls) -> console.log productUrls


opts =
    pageChunks:
        start: 2
        middle: 0
        end: 0
    sortOrder: 'helpful'
AmazonComScraper.scrapeProductReviews('http://www.amazon.com/Amazon-W87CUN-Fire-TV-Stick/dp/B00GDQ0RMG/ref=cm_cr_pr_product_top?ie=UTF8', opts).then (reviews) ->
    for review in reviews
        console.log review.title

# AmazonComScraper.scrapeProduct('http://www.amazon.com/Amazon-W87CUN-Fire-TV-Stick/dp/B00GDQ0RMG/ref=cm_cr_pr_product_top?ie=UTF8', 10).then (productData) ->
#     console.log productData
# AmazonComScraper.getPagesToScrape('http://www.amazon.com/Amazon-W87CUN-Fire-TV-Stick/dp/B00GDQ0RMG/ref=cm_cr_pr_product_top?ie=UTF8', 10).then (pagesToScrape) ->
#     console.log pagesToScrape
