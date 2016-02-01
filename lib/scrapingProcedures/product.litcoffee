    cheerio = require 'cheerio'
Scrape product information off a single product page

    module.exports = (body, context) ->
        $ = cheerio.load body

get default price

        price = Number $('#priceblock_ourprice').text().substr(1)

Sale prices have a different id. Capture default price.

        
        if price == 0
            try
                salePrice = Number $('#priceblock_saleprice').text().substr(1)
                priceElements = $('.a-span12.a-color-secondary.a-size-base.a-text-strike')
                price = Number $(priceElements[priceElements.length - 1]).text().substr(1)
            catch e
                e

capture book prices etc

        if price == 0
            try
                swatchPriceText = $('.swatchElement.selected .a-color-price').text()
                if swatchPriceText != ''
                    price = Number swatchPriceText.split('$')[1].split('\n')[0]
            catch e
                e

capture hidden, e.g. 'too low' prices etc

        if price == 0
            try
                hiddenPriceText = Number $('input[name="originPageBuyPrice.base"]')[0].attribs.value.split('|')[1].split('|')[0]
                price = hiddenPriceText
            catch e
                e
 
Throw error if no price was detected

        if (price == 0) && (salePrice == 0)
            throw new Error('Price of product' + name + ' could not be detected')

        avgRating = Number $('#avgRating span a span').text().trim().substr(0,3)
        productData =
            name: $('#productTitle').text()
            id: context.amazonProductId
            departmentId: context.departmentId
            price: price
            salePrice: salePrice
            avgRating: avgRating
        return productData
