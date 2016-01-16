# Amazon review scraper
A node module for scraping Amazon product reviews.
Developed in context of a study for the DHBW Mosbach.


## Installation
```
> npm i franzskuffka/amazon-review-scraper -s
```

## Usage
```
require('coffee-script/register'); // alpha is not compiled yet
Scraper = require('amazon-review-scraper');

scraper = new Scraper();

scraper.scrapeProductReviews(producturl).then(function (reviewData) {
    return console.log(reviewData);
});
```
