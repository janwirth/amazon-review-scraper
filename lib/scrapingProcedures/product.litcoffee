    cheerio = require 'cheerio'
Scrape product information off a single product page

    module.exports = (body, context) ->
        $ = cheerio.load body
        price = Number $('#priceblock_ourprice').text().substr(1)
        avgRating = Number $('#avgRating span a span').text().trim().substr(0,3)
        productData =
            name: $('#productTitle').text()
            id: context.amazonProductId
            departmentId: context.departmentId
            price: price
            avgRating: avgRating
        return productData
