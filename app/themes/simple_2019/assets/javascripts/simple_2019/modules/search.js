import {App} from "../core/facade";

export default (function() {

  let searchForm = document.querySelector('.m-search-box__form');
  let searchInput, searchHeaderResults, submitBtn;


  if (searchForm) {
    searchInput = searchForm.querySelector('#input_search_header');
    searchHeaderResults = document.querySelector('#search-header-results');
    submitBtn = searchForm.querySelector(".m-search-box__submit");
  }

  function init() {
    if (searchForm) {
      submitBtn.addEventListener("click", showSearchBox);
      suggestions();
    }
  }

  function suggestions() {

    searchForm.addEventListener('submit', function(ev) {
      selectShopFromSearchResults(ev);
      return;
    })

    searchInput.addEventListener('keyup', function(ev) {
      let $this = this;

      if (ev.keyCode === 38 || ev.keyCode === 40 || ev.keyCode === 27) {
        navigateOnSearchResults(ev.keyCode);
        return;
      }

      clearTimeout($this.dataset.timer);

      if ($this.value.length === 0) {
        searchHeaderResults.classList.add('hidden');
      } else {
        $this.dataset.timer = setTimeout(function() {
          axios.get($this.dataset.autocompleteUrl, {
            params: {
              query: $this.value
            },
            headers: {
              'X-Requested-With': 'XMLHttpRequest',
            }
          })
            .then(function(response) {
              let data = response.data;
              if (data.length > 0) {
                searchHeaderResults.innerHTML = data;
                searchHeaderResults.classList.remove('hidden');
              } else {
                searchHeaderResults.innerHTML = '';
                searchHeaderResults.classList.add('hidden');
              }
            });
        }, 300);
      }
    });

    searchInput.addEventListener('focusout', function() {
      setTimeout(function() {
        searchHeaderResults.classList.add('hidden');
      }, 300);
    });
  }

  function navigateOnSearchResults(key) {
    let currentItem, itemList, lastItem;
    itemList = searchHeaderResults.querySelectorAll('ul > li')
    currentItem = searchHeaderResults.querySelector('.active')
    lastItem = searchHeaderResults.querySelector('ul > li:last-child')

    if (itemList != null) {
      switch(key) {
        case 38:
          if (currentItem !== null && itemList.length > 1 && currentItem.previousElementSibling !== undefined && currentItem.previousElementSibling !== null) {
            currentItem.classList.remove('active')
            currentItem.previousElementSibling.classList.add('active')
          } else if (currentItem == null && itemList.length > 1) {
            lastItem.classList.add('active')
          }
          break;
        case 40:
          if (currentItem !== null && itemList.length > 1 && currentItem.nextElementSibling !== undefined && currentItem.nextElementSibling !== null) {
            currentItem.classList.remove('active')
            currentItem.nextElementSibling.classList.add('active')
          } else if (currentItem === null && itemList.length > 1) {
            itemList[0].classList.add('active')
          }
          break;
        case 27:
          if (currentItem !== null && currentItem !== undefined) {
            currentItem.classList.remove('acive')
          }
          searchHeaderResults.classList.add('hidden')
          break;
      }
    }
  }

  function selectShopFromSearchResults(ev) {
    let currentItem, url;
    currentItem = searchHeaderResults.querySelector('.active')
    if (currentItem !== null && currentItem !== undefined) {
      ev.preventDefault();
      url = currentItem.querySelector('a').href;
      window.location.href = url;
    }
  }

  function showSearchBox(ev) {
    if (App.Utils.isMobile.mobile() || App.Utils.isMobile.tabletPortrait()) {
      if (!submitBtn.classList.contains("m-search-box__submit--opened")) {
        ev.preventDefault();
      }
      submitBtn.classList.add("m-search-box__submit--opened");
      searchInput.classList.add("m-search-box__input--opened");

      document.addEventListener("click", clickOutside);

    }
  }

  function closeSearchBox() {
    submitBtn.classList.remove("m-search-box__submit--opened");
    searchInput.classList.remove("m-search-box__input--opened");
    document.removeEventListener("click", clickOutside);
  }

  function clickOutside(ev) {
    if (!ev.target.closest(".m-search-box__form")) {
      closeSearchBox();
    }
  }


  function run() {
    App.log("Search module");
    init();
  }

  return {
    run: run
  };
})();
