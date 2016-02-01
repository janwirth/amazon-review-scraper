    class Scraper
        scrape: (body, type, context) ->
            procedure = require './scrapingProcedures/' + type
            if body.indexOf('<title dir="ltr">Robot Check</title>') > -1
                throw new Error("Amazon thinks you are a robot. Reset your IP address")
            procedure body, context

    module.exports = Scraper
