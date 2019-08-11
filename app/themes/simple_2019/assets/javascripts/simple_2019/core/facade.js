/* global process */
/* eslint no-console: 0 */

require ('./polyfill');
import mediator from "./mediator";
import initializer from "./initializer";
import Utils from "../utilities";
import coupons from "../modules/coupons";
import vote from "../modules/vote";
import search from "../modules/search";
import category from "../modules/category";
import CouponFilters from "../modules/CouponFilters";
import CampaignCouponsFilter from "../modules/CampaignCouponsFilter";
import ModalClickout from "../modules/ModalClickout";
import widgets from "../widgets";
import ShopsIndex from "../modules/shops_index";

const App = (function() {
  return {
    start() {
      initializer.init();
    },
    coupons() {
      coupons.run();
    },
    CouponFilters(){
      CouponFilters.run();
    },
    CampaignCouponsFilter(){
      CampaignCouponsFilter.run();
    },
    vote() {
      vote.run();
    },
    search() {
      search.run();
    },
    category() {
      category.run();
    },
    widgets() {
      widgets.run();
    },
    modalClickout() {
      ModalClickout.run();
    },
    on(channel, fn) {
      mediator.on(channel, fn);
    },
    trigger(channel) {
      mediator.trigger(channel);
    },
    ShopsIndex() {
      ShopsIndex.run();
    },
    Utils: Utils,
    log() {
      if (process.env.NODE_ENV === "development") {
        return 'console' in window ? console.log.apply(console, arguments) : null;
      }
    }
  };
})();

export {App};
