Scraper = require './lib/index.coffee'
AmazonComScraper = new Scraper()


AmazonComScraper.getDepartmentProductUrls(undefined, 10).then(
#  (productUrls) -> console.log productUrls
)

AmazonComScraper.scrapeProductReviews('http://www.amazon.com/Fujifilm-INSTAX-Mini-Twin-Pack/dp/B00EB4ADQW/ref=zg_bs_electronics_8/188-6107668-5109001', 10)