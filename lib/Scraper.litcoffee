    class Scraper
        scrape: (body, type, context) ->
            procedure = require './scrapingProcedures/' + type
            procedure body, context
    module.exports = Scraper
