Scraper = require './lib/index.coffee'
AmazonComScraper = new Scraper()


AmazonComScraper.getDepartmentProductUrls(undefined, 10).then(
#  (productUrls) -> console.log productUrls
)

AmazonComScraper.scrapeProductReviews('http://www.amazon.com/Amazon-W87CUN-Fire-TV-Stick/dp/B00GDQ0RMG/ref=cm_cr_pr_product_top?ie=UTF8', 10).then (reviews) ->
        for review in reviews
            console.log review.id
