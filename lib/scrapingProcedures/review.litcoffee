        module.exports = ($, el, amazonProductId) =>
            reviewElement = el

            # required fields
            title = $($(el).find('.review-title')[0]).text()
            author = $($(el).find('.author')[0]).text()
            rating = parseInt $($(el).find('.review-rating ')[0]).text().substr 0,1
            dateArray = $(el.children[2].children[3]).text().split ' '
            date = new Date $($(el).find('.review-date')[0]).text().split('on ')[1]
            text = $($(el).find('.review-text')[0]).text()

            # optional fields
            getVotes = (el) ->
                votes =
                    helpful: 0
                    total: 0
                votesEl = $(el).find('.review-votes')[0]
                if votesEl?
                    votesText = $(votesEl).text()
                    votesTextSegments = votesText.split ' of '
                    votes.helpful = parseInt votesTextSegments[0].replace(/,/g, '')
                    votes.total = parseInt votesTextSegments[1].split(' people')[0].replace(/,/g, '')
                votes
            votes = getVotes(el)

            getComments = (el) ->
                commentCount = 0
                commentsEl = $(el).find('.review-comment-total')[0]
                if commentsEl?
                    commentCount = parseInt $(commentsEl).text()
                commentCount
            commentCount = getComments(el)

            # reviewer badges: vine, top1000 or top500
            badges = {}

            for rankRange in [10, 50, 100, 500, 1000]
                # push rank when element is found
                badges['top' + rankRange] = $(el).find('.c7y-badge-top-' + rankRange + '-reviewer')[0]?

            for specialbadge in ['hall-of-fame', 'vine-voice']
                badges[specialbadge] = $(el).find('.c7y-badge-' + specialbadge )[0]?

            # check is reviewed purchase is verified
            verified = $($(el).find('.review-data')[0].children[2]).text() == 'Verified Purchase'

            #  count images
            images = $($(el).find('.review-image-tile-section')[0])['0']
            if images?
                imageCount = 0
                for image in images.children
                    imageCount++ if image.attribs.src? if image.attribs?
            else
                imageCount = 0

            reviewData =
                id: reviewElement.attribs.id
                productId: amazonProductId
                rating: rating
                date: date

                title: title
                author: author
                text: text

                verified: verified
                badges: badges
                imageCount: imageCount
                votes: votes
                commentCount: commentCount

            return reviewData
