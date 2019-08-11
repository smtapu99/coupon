import Banners from "./Banners";
import Tracking from "./Tracking";
import Modal from "./Modal";
import ModalClickout from "./ModalClickout";
import Search from "./search";
import MNavigation from "./MNavigation";
import ImagesLazyLoad from "./ImagesLazyLoad";
import ScrollToTop from "./ScrollToTop";
import CookiesEU from "./CookiesEU";
import Flyout from "./Flyout";
import NewsLetters from "./NewsLetters";
import ShowMore from "./ShowMore";

export default (function() {
  return {
    run: () => {
      ImagesLazyLoad.run();
      Banners.run();
      Tracking.run();
      Modal.run();
      ModalClickout.run();
      Search.run();
      MNavigation.run();
      ScrollToTop.run();
      CookiesEU.run();
      Flyout.run();
      NewsLetters.run();
      ShowMore.run();
    }
  };
})();

