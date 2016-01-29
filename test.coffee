Scraper = require './lib/index.coffee'
AmazonComScraper = new Scraper()



opts =
    selectionAlgorithm: 'chunks'
    selectionAlgorithmParams:
        start: 2
        middle: 0
        end: 0
    sortOrder: 'helpful'

# AmazonComScraper.scrapeDepartmentProducts('http://www.amazon.com/Best-Sellers-Electronics-Office-Products/zgbs/electronics/172574/ref=zg_bs_nav_e_1_e', 10, opts).then (products) ->
#     console.log products.length
# 
# AmazonComScraper.scrapeProductReviews('http://www.amazon.com/Amazon-W87CUN-Fire-TV-Stick/dp/B00GDQ0RMG/ref=cm_cr_pr_product_top?ie=UTF8', opts).then (reviews) ->
#     console.log reviews.length
# 
# AmazonComScraper.scrapeProduct('http://www.amazon.com/Amazon-W87CUN-Fire-TV-Stick/dp/B00GDQ0RMG/ref=cm_cr_pr_product_top?ie=UTF8', 10).then (productData) ->
#     console.log productData
