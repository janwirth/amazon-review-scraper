Scraper = require './lib/index'
AmazonComScraper = new Scraper()



opts =
    selectionAlgorithm: 'chunks'
    selectionAlgorithmParams:
        start: 2
        middle: 0
        end: 0
    sortOrder: 'recent'

# AmazonComScraper.scrapeDepartmentProducts('http://www.amazon.com/Best-Sellers-Electronics-Office-Products/zgbs/electronics/172574/ref=zg_bs_nav_e_1_e', 10, opts).then (products) ->
#     console.log products.length

# AmazonComScraper.scrapeProductReviews('http://www.amazon.com/Amazon-W87CUN-Fire-TV-Stick/dp/B00GDQ0RMG/ref=cm_cr_pr_product_top?ie=UTF8', opts).then (reviews) ->
#     console.log reviews[0]

log = (data) ->
    console.log()
    console.log 'name', data.name
    console.log 'price', data.price
    console.log 'sale price', data.salePrice


productUrls =
    regular: 'http://www.amazon.com/Amazon-W87CUN-Fire-TV-Stick/dp/B00GDQ0RMG/ref=cm_cr_pr_product_top?ie=UTF8'
    book: 'http://www.amazon.com/When-Breath-Becomes-Paul-Kalanithi/dp/081298840X/'
    sale:
        '0': 'http://www.amazon.com/MWF-Replacement-Refrigerator-Pure-Line/dp/B00YV210RA/ref=zg_bs_appliances_3/176-7172457-4451057'
        '1': 'http://www.amazon.com/Maytag-UKF8001-Compatible-Refrigerator-Filters/dp/B00UIZLE48/ref=zg_bs_appliances_9/187-5637217-2768253'
        'noRegular': 'http://www.amazon.com/Colored-Pencil-Case-7-Inch-Pack/dp/B015OU8W3M/ref=zg_bs_toys-and-games_8/176-7663212-1534020'
    hiddenPrice:
        '0': 'http://www.amazon.com/Samsung-Galaxy-Tab-7-Inch-White/dp/B00J8DL78O/ref=zg_bs_pc_15/190-2933342-5606201'
        '1': 'http://www.amazon.com/HP-Black-Original-Cartridge-CH561WN/dp/B003H2GBM4/ref=zg_bs_office-products_1/187-7087478-6269030'

AmazonComScraper.scrapeProduct(productUrls.hiddenPrice['1']).then (productData) ->
    log productData
