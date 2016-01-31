    cheerio = require 'cheerio'
Scrape product information off a single product page

    module.exports = (body, context) ->
        $ = cheerio.load body
        price = Number $('#priceblock_ourprice').text().substr(1)

Sale prices have a different id. Capture default price.

        if price == 0
            price = Number $($('.a-span12.a-color-secondary.a-size-base.a-text-strike')[1]).text().substr(1)
            if price != 0
                salePrice = Number $('#priceblock_saleprice').text().substr(1)
        if price == 0
            price = Number $('.swatchElement.selected .a-color-price').text().split('$')[1].split('\n')[0]
 

        avgRating = Number $('#avgRating span a span').text().trim().substr(0,3)
        productData =
            name: $('#productTitle').text()
            id: context.amazonProductId
            departmentId: context.departmentId
            price: price
            salePrice: salePrice
            avgRating: avgRating
        return productData
