import {App} from "../core/facade";

export default (function() {

  function block_votes_if_voted() {
    let starRatingVoted = document.querySelector('.star-rating.star-rating--voted');
    if (starRatingVoted == null) {
      return
    }
    let starRatingVotedUL = starRatingVoted.querySelector('ul');
    starRatingVotedUL.style.pointerEvents = 'none';
    let starBtns = starRatingVotedUL.querySelectorAll('i');
    for (let i = 0; i < starBtns.length; i ++) {
      starBtns[i].style.opacity = '0.6';
    }
  }

  function block_and_recalculate_votes(star) {
    let starRating = document.querySelector('.star-rating');
    starRating.style.display = 'none';

    let review_count = document.querySelector('.star-rating__count');

    let total_reviews = parseInt(review_count.dataset.reviewCount) + 1;
    let total_stars = parseInt(starRating.dataset.totalStars) + star;
    let total_rating = (total_stars / total_reviews).toFixed(2);

    review_count.setAttribute('data-reviewCount', total_reviews);
    document.querySelector('.star-rating__value').setAttribute('data-ratingValue', total_rating.toString().replace(',', review_count.getAttribute('data-separator')));
  }

  function star_rating($this, options, callback) {
    let settings = {
      css_class: 'active',
      data_shop_id: $this.dataset.shopId,
      data_star: $this.dataset.star,
      data_votes: $this.dataset.votes
    };

    if (options) {
      settings = Object.assign({}, settings, options);
    }

    if (typeof($this) != 'undefined' && $this != null) {

      let starLIs = $this.querySelectorAll('li');
      for (let i = 0; i < $this.dataset.votes; i ++) {
        let starLI = starLIs[i];
        starLI.classList.add(settings.css_class);
        starLI.querySelector('i').classList.remove('icon-star-empty')
        starLI.querySelector('i').classList.add('icon-star')
      }
      if (document.querySelectorAll('.star-rating.voted').length) {
        block_votes_if_voted();
      }

      for (let i = 0; i < starLIs.length; i ++) {
        starLIs[i].addEventListener('mouseover', function(event) {
          let i = [...starLIs].indexOf(this);
          for (let j = 0; j < starLIs.length; j ++) {
            let starLI = starLIs[j]
            if (j <= i) {
              starLI.classList.add(settings.css_class);
              starLI.querySelector('i').classList.remove('icon-star-empty')
              starLI.querySelector('i').classList.add('icon-star')
            } else {
              starLI.classList.remove(settings.css_class);
              starLI.querySelector('i').classList.remove('icon-star')
              starLI.querySelector('i').classList.add('icon-star-empty')
            }
          }
        });
        starLIs[i].addEventListener('mouseout', function(event) {
          for (let j = 0; j < starLIs.length; j ++) {
            if (j < settings.data_votes) {
              starLIs[j].classList.add(settings.css_class);
              starLIs[j].querySelector('i').classList.remove('icon-star-empty')
              starLIs[j].querySelector('i').classList.add('icon-star')
            } else {
              starLIs[j].classList.remove(settings.css_class);
              starLIs[j].querySelector('i').classList.remove('icon-star')
              starLIs[j].querySelector('i').classList.add('icon-star-empty')
            }
          }
        });
        starLIs[i].addEventListener('click', function(e) {
          $this.style.display = 'none';
          let loader = document.querySelector('.loader--star');
          if (loader) {
            loader.style.display = '';
          }
          e.preventDefault();
          let starRatingLi = $this.closest('li')
          if (starRatingLi) {
            starRatingLi.classList.remove(settings.css_class);
            starRatingLi.querySelector('i').classList.remove('icon-star')
            starRatingLi.querySelector('i').classList.add('icon-star-empty')
          }
          let star = this.querySelector('span').dataset.star
          block_and_recalculate_votes(star);

          axios
            .get(root_dir + '/shops/vote', {
              params: {
                id: settings.data_shop_id,
                stars: star
              },
              headers: {
                'X-Requested-With': 'XMLHttpRequest',
              }
            })
            .then(function (response) {
              eval(response.data);
              $this = document.querySelector('.star-rating');
              let lis = $this.querySelectorAll('li');
              for (let j = 0; j < lis.length; j ++) {
                // lis[j].removeEventListener('click');
                lis[j].querySelector('.star-rating__star').setAttribute('disabled', true);
              }
              $this.style.display = '';

              let loader = document.querySelector('.loader--star');
              if (loader) {
                loader.style.display = 'none'
                // loader.parentNode.removeChild(loader);
              }
              block_votes_if_voted();
            })
        })
      }
    }
  }

  function init() {
    let $star_rating = document.querySelector('.star-rating');

    if ($star_rating.dataset.shopId > 0) {
      axios.get(root_dir + '/shops/render_votes', {
        params: {
          id: $star_rating.dataset.shopId
        },
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      .then(function (response) {
        eval(response.data);
        $star_rating = document.querySelector('.star-rating');
        $star_rating.style.display = '';
        star_rating($star_rating);
        let loader = document.querySelector('.loader--star');
        if (loader) {
          loader.style.display = 'none';
          // loader.parentNode.removeChild(loader);
        }
        block_votes_if_voted();
      })
    } else {
      star_rating($star_rating);
    }

    document.addEventListener('tracking_user_set', function(){
      block_votes_if_voted();
    });
  }

  function run() {
    App.log("Vote module");
    init();
  }

  return {
    run: run
  };
})();
